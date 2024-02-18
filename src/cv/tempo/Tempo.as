package cv.tempo {
	
	import cv.TempoLite;
	import cv.data.PlayList;
	import cv.events.MetaDataEvent;
	import cv.events.LoadEvent;
	import cv.events.PlayProgressEvent;
	import cv.tempo.PlayListEditor;
	import cv.tempo.Player;
	
	import flash.display.MovieClip;
	import flash.display.LoaderInfo;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	public class Tempo extends TempoLite {
		
		public static const PLAYER:String = 'player'; // Default name
		public static const PLAY_LIST:String = 'playlist'; // Default name
		
		private var _playerId:String = "1";
		private var _mute:Boolean = false;
		private var mcSkin:DisplayObjectContainer;
		private var ple:PlayListEditor;
		private var player:Player;
		private var sprHolder:Sprite = new Sprite();
		private var strMetaDataType:String;
		private var strFileName:String = "";
		private var c:Function; // call
		private var isEI:Boolean; // ExternalInterface.available
		private var aCb:Function; // addCallback
		private var hasScaled:Boolean = false;
		
		public function Tempo() {
			c = ExternalInterface.call;
			aCb = ExternalInterface.addCallback;
			isEI = ExternalInterface.available;
			
			// Skin Support
			this.addChild(sprHolder);
			
			// FlashVar Support
			initFlashVar();
			
			// JavaScript Support
			initJS();
		}
		
		public function get playerId():String {	return _playerId; }
		
		public function set playerId(value:String):void { _playerId = value; }
		
		override public function set volume(n:Number):void {
			super.volume = n;
			if(isEI) c("onVolume", n);
		}
		
		override public function set shuffle(b:Boolean):void {
			super.shuffle = b;
			if(isEI) c("onShuffle", b);
		}
		
		override public function set repeat(str:String):void {
			super.repeat = str;
			if(isEI) c("onRepeat", repeat);
		}
		
		// If no video metadata on size is available, we can figure it out
		// once the video has loaded enough, which we won't know til it's
		// happened. Which is why this check is in here.
		protected function autoSizeVideo():void {
			if(vidScreen) {
				if ((vidScreen.videoHeight || vidScreen.videoWidth) && !hasScaled) {
					hasScaled = true;
					setVideoScale(TempoLite.MAINTAIN_ASPECT_RATIO);
				}
			}
		}
		
		override protected function eventHandler(e:Event):void {
			switch(e.type) {
				case TempoLite.PLAY_COMPLETE :
					if(isEI) c("onPlayComplete");
					break;
				case TempoLite.REFRESH_PLAYLIST :
					if (ple) ple.refreshPlayList();
					break;
				case LoadEvent.LOAD_START :
					var le:LoadEvent = e as LoadEvent;
					var strURL:String = le.url;
					var arrURL:Array = (strURL.indexOf("\\") != -1) ? strURL.split("\\") : strURL.split("/");
					strFileName = arrURL[arrURL.length - 1];
					strMetaDataType = null;
					
					if (player) {
						if (le.mediaType == TempoLite.AUDIO) player.goNormalScreen();
						player.setStatus();
						player.title = strFileName;
						player.timeTotal = le.time;
						autoSizeVideo();
					}
					
					if(isEI) c("onLoad", {url:le.url, type:le.mediaType, time:le.time});
					break;
				case PlayProgressEvent.PLAY_PROGRESS :
					var ppe:PlayProgressEvent = e as PlayProgressEvent;
					if(player) {
						if (player.getStatus() != Player.PLAY) player.setStatus(Player.PLAY);
						player.timeTotal = ppe.total;
						player.time = ppe.elapsed;
						player.time2 = ppe.remain;
						player.trackPosition = ppe.percent / 100;
					}
					
					autoSizeVideo();
					
					if(isEI) c("onPlayProgress", { percent:ppe.percent, elapsed:ppe.elapsed, remain:ppe.remain, total:ppe.total });
					break;
				case TempoLite.LOAD_PROGRESS :
					var pe:ProgressEvent = e as ProgressEvent;
					var o:Object = { loaded:pe.bytesLoaded, total:pe.bytesTotal };
					if (player) player.loadProgress = o;
					
					if(isEI) c("onLoadProgress", o);
					break;
			}
		}
		
		protected function initFlashVar():void {
			var fv:Object = LoaderInfo(this.loaderInfo).parameters;
			
			for (var key:String in fv) {
				var val:String = fv[key];
				if (key == "fileURL") {
					if (!isEmpty(val)) {
						loadMedia(fv['fileURL']);
					}
				} else if (key == "enableJS") {
					if (!isEmpty(val)) {
						if (!isEI) continue;
						if (Security.sandboxType == "localWithFile" && val != "true") {
							isEI = false;
						} else {
							isEI = Boolean(val);
						}
					}
				} else {
					if (this.hasOwnProperty(key)) {
						if(!isEmpty(val)) {
							this[key] = val;
						}
					}
				}
			}
			
			// If these aren't set, load defaults
			if (isEmpty(fv['fileURL'])) loadPlayList(fv['playlistURL']);
			loadSkin(fv['skinURL']);
		}
		
		protected function initJS():void {
			if (isEI) {
                try {
					// Methods
					aCb("play", 				play);
					aCb("playpause", 			pause);
					aCb("pause", 				pause);
					aCb("stop", 				stop);
					aCb("next", 				next);
					aCb("prev", 				previous);
					aCb("playItem", 			play); // (idx:int)
					aCb("loadFile", 			loadMedia); 	// (url:String, autoStart:Boolean = true)
																// (obj:PlayListObject) : {file:url, image:url/image, captions:url/xml}, file, image, id, link, type, captions, audio, title, author
					aCb("addItem", 				addItem); 	// PlayListObject {url:String, title:String = "", length:int = -1}
																// (obj:PlayListObject, idx:Number) : Add item to end of playlist if idx isn't there
					aCb("removeItem", 			removeItem); // (idx:number) : Remove item, last item removed if idx isn't there
					aCb("clearItems", 			clearItems);
					aCb("mute", 				setMute); // (b:Boolean)
					aCb("loadSkin", 			loadSkin); // (str:String = "DefaultSkin.swf")
					aCb("loadPlayList", 		loadPlayList); // (str:String = "playlists/Tempo.m3u")
					
					// Properties
					aCb("setId", 				function(n:String):void { playerId = n }); // String
					aCb("getId", 				function():String {return playerId});
					aCb("setRepeat", 			function(str:String):void { repeat = str }); // (bool)
					aCb("getRepeat", 			function():String {return repeat});
					aCb("setShuffle", 			function(b:Boolean):void { shuffle = b }); // (bool)
					aCb("getShuffle", 			function():Boolean {return shuffle});
					aCb("setVolume", 			function(n:Number):void { volume = n }); // [, percent]
					aCb("getVolume", 			function():Number { return volume } );
					//aCb("setSeekTime", 		setSeekTime); // [, seconds]
					//aCb("getSeekTime", 		mP.timeCurrent); // BUG: can't add becuase this is specific to the player view and can't be accessed by TempoLite
					aCb("setSeekPercent", 		seekPercent); //[, percent]
					aCb("getSeekPercent", 		getCurrentPercent);
					aCb("getItemData", 			plM.list.getCurrent); // Returns playlist object data
					aCb("getItemIndex", 		function():uint {return plM.list.index});
					aCb("getLength", 			function():uint {return plM.list.length}); // Playlist Length
					aCb("getLoadPercent", 		function():Number {return (getLoadCurrent() / getLoadTotal()) * 100});
					//aCb("getPlayerState", 	receivedFromJavaScript);
					aCb("getTimeElapsed", 		getTimeCurrent);
					aCb("getTimeRemaining", 	getTimeLeft);
					
					aCb("getObjectID", 		function():String {return ExternalInterface.objectID}); // Unique SWF object ID in the html
                } catch (error:SecurityError) {
					trace("Tempo::initJS - " + error.message);
                } catch (error:Error) {
					trace("Tempo::initJS - " + error.message);
                }
            } else {
                trace("Tempo::initJS - Error : External interface is not available.");
            }
		}
		
		protected function ioErrorHandler(e:IOErrorEvent):void {
			trace("Tempo::loadSkin - " + e.text);
        }
		
		protected function isEmpty(str:String):Boolean {
			if (!str) return true;
			return !str.length;
		}
		
		override protected function load(o:Object):void {
			super.load(o);
			hasScaled = false;
		}
		
		protected function loadSkin(s:String = "DefaultSkin.swf"):void {
			if (mcSkin) sprHolder.removeChild(mcSkin);
			if (s == null) s = "DefaultSkin.swf";
			
			skinLoader = new Loader();
			skinLoader.load(new URLRequest(s));
			skinLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, skinLoadedHandler);
			skinLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		override protected function metaDataHandler(e:MetaDataEvent):void {
			var o:Object = e.data;
			switch(e.type) {
				case MetaDataEvent.AUDIO_METADATA :
					// Default
					if (o.TLEN) plM.updateItemLength(plM.list.index, o.TLEN);
					
					// Playlist
					if ((o.artist || o.TPE1) && (o.songname || o.TIT2)) {
						plM.updateItemTitle(plM.list.index, (!o.artist ? o.TPE1 : o.artist) + " - " + (!o.songname ? o.TIT2 : o.songname));
						if (ple) ple.refreshPlayList();
					}
					
					// Player
					strMetaDataType = TempoLite.AUDIO;
					if(player) player.setAudMetaData(o);
					break;
				case MetaDataEvent.VIDEO_METADATA :
					// Default
					if (o.duration) plM.updateItemLength(plM.list.index, o.duration * 1000);
					
					// Player
					strMetaDataType = TempoLite.VIDEO;
					if (o.height && o.width) autoSizeVideo();
					break;
			}
			
			if(isEI) c("onMetaData", o);
		}
		
		protected function onPLChange(e:Event):void {
			play(ple.selectedIndex);
		}
		
		override public function play(index:int = -1):void {
			super.play(index);
			if(isEI) c("onPlay");
		}
		
		override protected function playlistHandler(e:Event):void {
			switch(e.type) {
				case TempoLite.NEXT :
					next();
					dispatchEvent(e.clone());
					break;
				case TempoLite.NEW_PLAYLIST :
					if (plM.autoStart) {
						var l:PlayList = plM.list;
						l.index = plM.autoStartIndex;
						if(l.getCurrent()) load(l.getCurrent());
					}
					
					// Reset listeners
					plM.list.removeEventListener(TempoLite.CHANGE, eventHandler);
					plM.list.addEventListener(TempoLite.CHANGE, eventHandler);
					
					if (ple) ple.list = plM.list;
					break;
			}
		}
		
		protected function playerHandler(e:Event):void {
			switch(e.type) {
				case Player.PLAY :
					play();
					break;
				case Player.STOP :
					stop();
					break;
				case Player.PAUSE :
					pause(true);
					break;
				case Player.VOLUME :
					volume = player.volume;
					if(_mute == true) {
						player.mute = _mute = false;
						setMute(_mute);
					}
					break;
				case Player.REPEAT :
					if(repeat == TempoLite.REPEAT_NONE) {
						repeat = TempoLite.REPEAT_ALL;
					} else if(repeat == TempoLite.REPEAT_ALL) {
						repeat = TempoLite.REPEAT_TRACK;
					} else {
						repeat = TempoLite.REPEAT_NONE;
					}
					
					player.repeat = repeat;
					break;
				case Player.SHUFFLE :
					shuffle = !shuffle;
					player.shuffle = shuffle;
					break;
				case Player.MUTE :
					_mute = !_mute;
					player.mute = _mute;
					setMute(_mute);
					break;
				case Player.NEXT :
					next();
					break;
				case Player.PREVIOUS :
					previous();
					break;
				case Player.SEEK :
					seekPercent(player.trackPosition);
					break;
				case Player.SET_SCREEN :
					setVideoScreen(player.video);
					autoSizeVideo();
					break;
			}
		}
		
		protected function skinLoadedHandler(e:Event):void {
			mcSkin = skinLoader.content as DisplayObjectContainer;
			var mc:MovieClip = mcSkin.getChildByName(PLAYER);
			
			// Set Player
			if (player) {
				player.removeEventListener(Player.MUTE, playerHandler);
				player.removeEventListener(Player.PAUSE, playerHandler);
				player.removeEventListener(Player.PLAY, playerHandler);
				player.removeEventListener(Player.STOP, playerHandler);
				player.removeEventListener(Player.VOLUME, playerHandler);
				player.removeEventListener(Player.SHUFFLE, playerHandler);
				player.removeEventListener(Player.REPEAT, playerHandler);
				player.removeEventListener(Player.SEEK, playerHandler);
				player.removeEventListener(Player.NEXT, playerHandler);
				player.removeEventListener(Player.PREVIOUS, playerHandler);
				player.removeEventListener(Player.SET_SCREEN, playerHandler);
			}
			
			if (mc != null) {
				player = new Player();
				player.addEventListener(Player.SET_SCREEN, playerHandler);
				player.addEventListener(Player.MUTE, playerHandler);
				player.addEventListener(Player.PAUSE, playerHandler);
				player.addEventListener(Player.PLAY, playerHandler);
				player.addEventListener(Player.STOP, playerHandler);
				player.addEventListener(Player.VOLUME, playerHandler);
				player.addEventListener(Player.SHUFFLE, playerHandler);
				player.addEventListener(Player.REPEAT, playerHandler);
				player.addEventListener(Player.SEEK, playerHandler);
				player.addEventListener(Player.NEXT, playerHandler);
				player.addEventListener(Player.PREVIOUS, playerHandler);
				player.startUp(mc);
				
				player.title = strFileName;
				player.volume = volume;
				player.mute = _mute;
				player.shuffle = shuffle;
				player.repeat = repeat;
				player.trackPosition = cM.currentPercent / 100;
				if (strMetaDataType) {
					if (strMetaDataType == TempoLite.AUDIO) {
						player.setAudMetaData(cM.metaData);
					} else if (strMetaDataType == TempoLite.VIDEO) {
						//player.setVidMetaData(cM.metaData);
					}
				}
			} else {
				player = null;
			}
			
			// Set PlayList Editor
			mc = mcSkin.getChildByName(PLAY_LIST) as MovieClip;
			if (ple) ple.removeEventListener(Event.CHANGE, onPLChange);
			if (mc) {
				ple = new PlayListEditor(mc);
				ple.list = plM.list;
				ple.addEventListener(Event.CHANGE, onPLChange);
			} else {
				ple = null;
			}
			
			sprHolder.addChild(mcSkin);
		}
	}
}