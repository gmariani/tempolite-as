package cv.tempo {
	
	import cv.interfaces.IMediaPlayer;
	import cv.media.ImagePlayer;
	import cv.media.RTMPPlayer;
	import cv.media.SoundPlayer;
	import cv.TempoLite;
	import cv.data.PlayList;
	import cv.events.MetaDataEvent;
	import cv.events.LoadEvent;
	import cv.events.PlayProgressEvent;
	import flash.display.DisplayObject;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.FullScreenEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.utils.setInterval;
	
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
	
	public class Tempo extends Sprite {
		
		protected var c:Function; // call
		protected var isEI:Boolean; // ExternalInterface.available
		protected var aCb:Function; // addCallback
		protected var tempo:TempoLite;
		protected var sndP:SoundPlayer;
		protected var rtP:RTMPPlayer;
		protected var vidFullScreen:Video;
		protected var loadFlag:Boolean = false;
		
		protected var err:MediaError;
		protected var _src:String;
		protected var _currentSrc:String;
		// crossOrigin
		protected var _networkState:uint = NetworkState.NETWORK_EMPTY;
		protected var _preload:String = Preload.NONE;
		protected var _readyState:uint = ReadyState.HAVE_NOTHING;
		protected var _seeking:Boolean = false;
		protected var _startDate:Date; // TODO: set when starts playing
		protected var _controls:Boolean = false; // TODO
		protected var _defaultMuted:Boolean = false; // TODO
		
		// Poster
		protected var ldr:Loader;
		protected var _poster:String;
		
		public function Tempo() {
			c = ExternalInterface.call;
			aCb = ExternalInterface.addCallback;
			isEI = ExternalInterface.available;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, resizeHandler); 
			
			// Tempo
			sndP = new SoundPlayer();
			sndP.debug = true;
			
			rtP = new RTMPPlayer();
			rtP.autoScale = true;
			rtP.autoRewind = true;
			rtP.video = vidScreen;
			rtP.debug = true;
			rtP.addEventListener(ErrorEvent.ERROR, tempoHandler);
			
			tempo = new TempoLite([rtP, sndP]);
			tempo.autoStart = false;
			tempo.addEventListener(PlayProgressEvent.PLAY_START, tempoHandler);
			tempo.addEventListener(PlayProgressEvent.PLAY_PROGRESS, tempoHandler);
			tempo.addEventListener(PlayProgressEvent.PLAY_COMPLETE, tempoHandler);
			tempo.addEventListener(LoadEvent.LOAD_START, tempoHandler);
			tempo.addEventListener(LoadEvent.LOAD_PROGRESS, tempoHandler);
			tempo.addEventListener(LoadEvent.LOAD_COMPLETE, tempoHandler);
			tempo.addEventListener(MetaDataEvent.METADATA, tempoHandler);
			tempo.addEventListener(TempoLite.VOLUME, tempoHandler);
			tempo.addEventListener(PlayProgressEvent.STATUS, tempoHandler);
			tempo.addEventListener(Event.CHANGE, tempoHandler);
			
			// FlashVar Support
			var fv:Object = LoaderInfo(this.loaderInfo).parameters;
			
			/**
			 * Move this FlashVar to the end so it's consistant when read in
			 */
			var doAutoPlay:Boolean = false; 
			for (var key:String in fv) {
				var val:String = fv[key];
				if (key == "enableJS") {
					if (!isEmpty(val)) {
						if (!isEI) continue;
						if ((Security.sandboxType == "localWithFile" || Security.sandboxType == "localTrusted") && val != "true") {
							isEI = false;
						} else {
							isEI = Boolean(val);
						}
					}
				} else {
					if (this.hasOwnProperty(key)) {
						if (!isEmpty(val)) {
							if (key.toLowerCase() == 'autoplay' && val.toLowerCase() == 'true') {
								doAutoPlay = true;
							} else {
								this[key] = val;
							}
						}
					}
				}
			}
			
			// JavaScript Support
			if (isEI) {
                try {
					// Flash
					aCb("setStreamHost", 			function(str:String):void { streamHost = str; } );
					aCb("getStreamHost", 			function():String { return streamHost; } );
					
					// Fullscreen API
					aCb("requestFullscreen", 		requestFullscreen ); // Method
					aCb("exitFullscreen", 			exitFullscreen ); // Method
					aCb("fullscreenEnabled", 		function():Boolean { return fullscreenEnabled; } );
					
					// HTMLVideoElement
					// preload [none, metadata, auto]
					aCb("setWidth", 				function(n:Number):void { vidScreen.width = n; } );
					aCb("getWidth", 				function():Number { return vidScreen.width; } );
					aCb("setHeight", 				function(n:Number):void { vidScreen.height = n; } );
					aCb("getHeight", 				function():Number { return vidScreen.height; } );
					aCb("videoWidth", 				function():Number { return vidScreen.width; } ); // ReadOnly
					aCb("videoHeight", 				function():Number { return vidScreen.height; } ); // ReadOnly
					aCb("setPoster", 				function(str:String):void { poster = str; } );
					aCb("getPoster", 				function():String { return poster; } );
					
					// HTMLMediaElement
					// error state
					aCb("error", 					function():MediaError { return err;  } ); // ReadOnly MediaError

					// network state
					aCb("setSrc", 					function(str:String):void { src = str; } );
					aCb("getSrc", 					function():String { return src; } );
					aCb("currentSrc", 				function():String { return currentSrc; } ); // ReadOnly
					//aCb("setCrossOrigin", 			function(str:String):void { crossOrigin = str; } ); // Doesn't apply to flash
					//aCb("getCrossOrigin", 			function():String { return crossOrigin;  } );
					aCb("networkState", 			function():uint { return networkState; } ); // ReadOnly
					aCb("setPreload", 				function(str:String):void { preload = str; } );
					aCb("getPreload", 				function():String { return preload;  } );
					aCb("buffered", 				function():Array { return buffered; } ); // ReadOnly TimeRanges
					aCb("load", 					load ); // Method
					aCb("canPlayType", 				canPlayType );
					
					// ready state
					aCb("readyState", 				function():uint { return readyState; } ); // ReadOnly
					aCb("seeking", 					function():Boolean { return seeking; } ); // ReadOnly
					
					// playback state
					aCb("setCurrentTime", 			function(n:Number):void { currentTime = n; } );
					aCb("getCurrentTime", 			function():Number { return currentTime; } );
					aCb("duration", 				function():Number { return duration;  } ); // ReadOnly
					aCb("startDate", 				function():Date { return startDate;  } ); // ReadOnly
					aCb("paused", 					function():Boolean { return paused;  } ); // ReadOnly
					aCb("setDefaultPlaybackRate", 	function(n:Number):void { } ); // Can't change play speed in Flash
					aCb("getDefaultPlaybackRate", 	function():Number { return 1; } );
					aCb("setPlaybackRate", 			function(n:Number):void { } ); // Can't change play speed in Flash
					aCb("getPlaybackRate", 			function():Number { return 1; } );
					aCb("played", 					function():Array { return []; } ); // ReadOnly TimeRanges
					aCb("seekable", 				function():Array { return []; } ); // ReadOnly TimeRanges
					aCb("ended", 					function():Boolean { return ended; } ); // ReadOnly
					aCb("setAutoplay", 				function(b:Boolean):void { autoPlay = b; } );
					aCb("getAutoplay", 				function():Boolean { return autoPlay; } );
					aCb("setLoop", 					function(b:Boolean):void { loop = b; } );
					aCb("getLoop", 					function():Boolean { return loop; } );
					aCb("play", 					play ); // Method
					aCb("pause", 					pause ); // Method
					
					// media controller - Not supported by majorbrowsers
					//aCb("setMediaGroup", 			function(str:String):void { } );
					//aCb("getMediaGroup", 			function():String { } );
					//aCb("setController", 			function(o:Object):void { } ); // MediaController
					//aCb("getController", 			function():Object { } ); // MediaController
					
					// controls
					aCb("setControls", 				function(b:Boolean):void { controls = b; } );
					aCb("getControls", 				function():Boolean { return controls;  } );
					aCb("setVolume", 				function(n:Number):void { volume = n } );
					aCb("getVolume", 				function():Number { return volume } );
					aCb("setMuted", 				function(b:Boolean):void { muted = b; } );
					aCb("getMuted", 				function():Boolean { return muted; } );
					aCb("setDefaultMuted", 			function(b:Boolean):void { defaultMuted = b; } );
					aCb("getDefaultMuted", 			function():Boolean { return defaultMuted; } );
					
					// tracks - Not supported by majorbrowsers
					//aCb("audioTracks", 			function():Object { } ); // ReadOnly AudioTrackList
					//aCb("videoTracks", 			function():Object { } ); // ReadOnly VideoTrackList
					//aCb("textTracks", 			function():Object { } ); // ReadOnly TextTrackList
					//aCb("addTextTrack", 			function(kind:String, label:String = '', language:String = ''):Object { } ); // TextTrack
                } catch (error:SecurityError) {
					trace("Tempo::constructor - " + error.message);
                } catch (error:Error) {
					trace("Tempo::constructor - " + error.message);
                }
            } else {
                trace("Tempo::constructor - External interface is not available.");
            }
			
			if (doAutoPlay) this.load();
		}
		
		protected function autoSize(t:DisplayObject):void {
			if (!t) return;
			var newWidth:Number = (t.width * stage.stageHeight / t.height);
			var newHeight:Number = (t.height * stage.stageWidth / t.width);
			if (newHeight < stage.stageHeight) {
				t.width = stage.stageWidth;
				t.height = newHeight;
			} else if (newWidth < stage.stageWidth) {
				t.width = newWidth;
				t.height = stage.stageHeight;
			} else {
				t.width = stage.stageWidth;
				t.height = stage.stageHeight;
			}
			
			t.x = (stage.stageWidth - t.width) / 2;
			t.y = (stage.stageHeight - t.height) / 2;
		}
		
		protected function resizeHandler(e:Event = null):void {
			autoSize(ldr);
			autoSize(vidScreen);
		}
		
		/*
		   attribute EventHandler onemptied;
           attribute EventHandler onloadedmetadata;
           attribute EventHandler onloadeddata;
           attribute EventHandler oncanplay;
           attribute EventHandler oncanplaythrough;
           attribute EventHandler onplaying;
           attribute EventHandler onended;
           attribute EventHandler onwaiting;

           attribute EventHandler ondurationchange;
           attribute EventHandler ontimeupdate;
           attribute EventHandler onplay;
           attribute EventHandler onpause;
           attribute EventHandler onratechange;
           attribute EventHandler onvolumechange;
		   
	loadstart	Event	The user agent begins looking for media data, as part of the resource selection algorithm.	networkState equals NETWORK_LOADING
	progress	Event	The user agent is fetching media data.	networkState equals NETWORK_LOADING
suspend	Event	The user agent is intentionally not currently fetching media data.	networkState equals NETWORK_IDLE
abort	Event	The user agent stops fetching the media data before it is completely downloaded, but not due to an error.	error is an object with the code MEDIA_ERR_ABORTED. networkState equals either NETWORK_EMPTY or NETWORK_IDLE, depending on when the download was aborted.
error	Event	An error occurs while fetching the media data.	error is an object with the code MEDIA_ERR_NETWORK or higher. networkState equals either NETWORK_EMPTY or NETWORK_IDLE, depending on when the download was aborted.
emptied	Event	A media element whose networkState was previously not in the NETWORK_EMPTY state has just switched to that state (either because of a fatal error during load that's about to be reported, or because the load() method was invoked while the resource selection algorithm was already running).	networkState is NETWORK_EMPTY; all the IDL attributes are in their initial states.
stalled	Event	The user agent is trying to fetch media data, but data is unexpectedly not forthcoming.	networkState is NETWORK_LOADING.
	loadedmetadata	Event	The user agent has just determined the duration and dimensions of the media resource and the text tracks are ready.	readyState is newly equal to HAVE_METADATA or greater for the first time.
loadeddata	Event	The user agent can render the media data at the current playback position for the first time.	readyState newly increased to HAVE_CURRENT_DATA or greater for the first time.
canplay	Event	The user agent can resume playback of the media data, but estimates that if playback were to be started now, the media resource could not be rendered at the current playback rate up to its end without having to stop for further buffering of content.	readyState newly increased to HAVE_FUTURE_DATA or greater.
canplaythrough	Event	The user agent estimates that if playback were to be started now, the media resource could be rendered at the current playback rate all the way to its end without having to stop for further buffering.	readyState is newly equal to HAVE_ENOUGH_DATA.
playing	Event	Playback is ready to start after having been paused or delayed due to lack of media data.	readyState is newly equal to or greater than HAVE_FUTURE_DATA and paused is false, or paused is newly false and readyState is equal to or greater than HAVE_FUTURE_DATA. Even if this event fires, the element might still not be potentially playing, e.g. if the element is blocked on its media controller (e.g. because the current media controller is paused, or another slaved media element is stalled somehow, or because the media resource has no data corresponding to the media controller position), or the element is paused for user interaction or paused for in-band content.
waiting	Event	Playback has stopped because the next frame is not available, but the user agent expects that frame to become available in due course.	readyState is equal to or less than HAVE_CURRENT_DATA, and paused is false. Either seeking is true, or the current playback position is not contained in any of the ranges in buffered. It is possible for playback to stop for other reasons without paused being false, but those reasons do not fire this event (and when those situations resolve, a separate playing event is not fired either): e.g. the element is newly blocked on its media controller, or playback ended, or playback stopped due to errors, or the element has paused for user interaction or paused for in-band content.
seeking	Event	The seeking IDL attribute changed to true.	
seeked	Event	The seeking IDL attribute changed to false.	
	ended	Event	Playback has stopped because the end of the media resource was reached.	currentTime equals the end of the media resource; ended is true.
durationchange	Event	The duration attribute has just been updated.	
	timeupdate	Event	The current playback position changed as part of normal playback or in an especially interesting way, for example discontinuously.	
play	Event	The element is no longer paused. Fired after the play() method has returned, or when the autoplay attribute has caused playback to begin.	paused is newly false.
pause	Event	The element has been paused. Fired after the pause() method has returned.	paused is newly true.
ratechange	Event	Either the defaultPlaybackRate or the playbackRate attribute has just been updated.	
volumechange	Event	Either the volume attribute or the muted attribute has changed. Fired after the relevant attribute's setter has returned.	
		   
		   */
		
		protected function tempoHandler(e:Event):void {
			switch(e.type) {
				case TempoLite.VOLUME :
					c('flashEvent', 'volumechange');
					break;
				case PlayProgressEvent.PLAY_START :
					readyState = ReadyState.HAVE_ENOUGH_DATA;
					if (loadFlag) c('flashEvent', 'loadeddata');
					break;
				case PlayProgressEvent.PLAY_PROGRESS :
					c('flashEvent', 'timeupdate');
					break;
				case PlayProgressEvent.PLAY_COMPLETE :
					c('flashEvent', 'ended');
					break;
				case LoadEvent.LOAD_START :
					c('flashEvent', 'loadstart');
					networkState = NetworkState.NETWORK_LOADING;
					break;
				case LoadEvent.LOAD_PROGRESS :
					c('flashEvent', 'progress');
					break;
				case LoadEvent.LOAD_COMPLETE :
					c('flashEvent', 'progress');
					networkState = NetworkState.NETWORK_IDLE;
					c('flashEvent', 'suspend');
					break;
				case MetaDataEvent.METADATA :
					c('flashEvent', 'durationchange');
					resizeHandler();
					readyState = ReadyState.HAVE_METADATA;
					break;
				case ErrorEvent.ERROR :
					var type:String = ErrorEvent(e).text;
					if (type == 'failed') {
						err = new MediaError(MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED);
						networkState = NetworkState.NETWORK_NO_SOURCE;
						c('flashEvent', 'error');
					} else if (type == 'decode') {
						err = new MediaError(MediaError.MEDIA_ERR_DECODE);
						c('flashEvent', 'error');
						if (readyState == ReadyState.HAVE_NOTHING) {
							networkState = NetworkState.NETWORK_EMPTY;
							c('flashEvent', 'emptied');
						} else {
							networkState = NetworkState.NETWORK_IDLE;
						}
					}
			}
		}
		
		protected function errorHandler(e:ErrorEvent):void {
			trace("Poster - Error : " + e.text);
		}
		
		protected function posterHandler(e:Event):void {
			autoSize(ldr);
		}
		
		public function get poster():String {
			return _poster;
		}
		
		public function set poster(str:String):void {
			_poster = str;
			
			// Cancel loading poster if one is in progress
			if (ldr && ldr.contentLoaderInfo) {
				if(ldr.contentLoaderInfo.bytesLoaded != ldr.contentLoaderInfo.bytesTotal) {
					ldr.close();
				} else {
					ldr.unload();
				}
				ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, posterHandler);
				this.removeChild(ldr);
				ldr = null;
			}
			
			if (!str) return;
			
			ldr = new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, posterHandler, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			ldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
			ldr.load(new URLRequest(_poster));
			this.addChildAt(ldr, 0);
		}
		
		public function get src():String {
			return _src;
		}
		
		public function set src(str:String):void {
			_src = str;
			if (autoPlay) {
				c('flashEvent', 'play');
				load();
			}
		}
		
		public function get streamHost():String {
			return rtP.streamHost;
		}
		
		public function set streamHost(str:String):void {
			rtP.streamHost = str;
		}
		
		public function get currentSrc():String {
			return _currentSrc;
		}
		
		public function get networkState():uint {
			return _networkState;
		}
		
		// private
		public function set networkState(n:uint):void {
			_networkState = n;
		}
		
		public function get preload():String {
			return _preload;
		}
		
		public function set preload(str:String):void {
			switch (str) {
				case 'auto' :
				case 'metadata' :
				case 'none' :
				case '' :
					_preload = str;
					break;
				default : return;
			}
		}
		
		// In bytes not seconds like in html
		public function get buffered():Array {
			// Return all buffered segments
			var arr:Array = [];
			// start, end
			arr[0] = [0, tempo.loadCurrent];
			
			return arr;
		}
		
		public function get readyState():uint {
			return _readyState;
		}
		
		// private
		public function set readyState(n:uint):void {
			if (readyState == ReadyState.HAVE_NOTHING && n == ReadyState.HAVE_METADATA) {
				c('flashEvent', 'loadedmetadata');
			}
			
			if (readyState == ReadyState.HAVE_METADATA && n >= ReadyState.HAVE_CURRENT_DATA) {
				if (loadFlag) c('flashEvent', 'loadeddata');
				loadFlag = false; // If this is the first time this occurs for this media element since the load() algorithm was last invoked
				// if (n >= ReadyState.HAVE_FUTURE_DATA)
			}
			
			if (readyState >= ReadyState.HAVE_FUTURE_DATA && n <= ReadyState.HAVE_CURRENT_DATA) {
				if (!ended && !paused) { // and no errors
					c('flashEvent', 'timeupdate');
					c('flashEvent', 'waiting');
				}
			}
			
			if (readyState <= ReadyState.HAVE_CURRENT_DATA && n == ReadyState.HAVE_FUTURE_DATA) {
				c('flashEvent', 'canplay');
				if (!paused) c('flashEvent', 'playing');
			}
			
			if (n == ReadyState.HAVE_ENOUGH_DATA) {
				if (readyState <= ReadyState.HAVE_CURRENT_DATA) {
					c('flashEvent', 'canplay');
					if (!paused) c('flashEvent', 'playing');
				}
				
				if (autoPlay && paused) {
					tempo.pause(false);
					c('flashEvent', 'play');
					c('flashEvent', 'playing');
				}
				
				c('flashEvent', 'canplaythrough');
			}
			
			_readyState = n;
		}
		
		public function get seeking():Boolean {
			return _seeking;
		}
		
		public function get currentTime():Number {
			return tempo.timeCurrent / 1000;
		}
		
		public function set currentTime(n:Number):void {
			tempo.seek(n);
		}
		
		public function get duration():Number {
			return (tempo.timeTotal / 1000) || NaN;
		}
		
		public function get startDate():Date {
			return _startDate;
		}
		
		public function get paused():Boolean {
			return tempo.paused;
		}
		
		public function get ended():Boolean {
			return tempo.timeCurrent >= tempo.timeTotal;
		}
		
		public function get autoPlay():Boolean {
			return tempo.autoStart;
		}
		
		public function set autoPlay(b:Boolean):void {
			tempo.autoStart = b;
		}
		
		public function get loop():Boolean {
			return (tempo.repeat == TempoLite.REPEAT_TRACK);
		}
		
		public function set loop(b:Boolean):void {
			tempo.repeat = b ? TempoLite.REPEAT_TRACK : TempoLite.REPEAT_NONE;
		}
		
		public function get controls():Boolean {
			return _controls;
		}
		
		public function set controls(b:Boolean):void {
			_controls = b;
		}
		
		public function get volume():Number {
			return tempo.volume;
		}
		
		public function set volume(n:Number):void {
			tempo.volume = n;
		}
		
		public function get muted():Boolean {
			return tempo.muted;
		}
		
		public function set muted(b:Boolean):void {
			tempo.muted = b;
		}
		public function get defaultMuted():Boolean {
			return _defaultMuted;
		}
		
		public function set defaultMuted(b:Boolean):void {
			_defaultMuted = b;
		}
		
		public function get fullscreenEnabled():Boolean {
			return (stage.displayState == StageDisplayState.FULL_SCREEN);
		}
		
		public function load():void {
			// calls stop, seeks to 0 and pauses
			tempo.unload();
			
			if (networkState == NetworkState.NETWORK_LOADING || networkState == NetworkState.NETWORK_IDLE) {
				c('flashEvent', 'abort');
			}
			
			if (networkState != NetworkState.NETWORK_EMPTY) {
				c('flashEvent', 'emptied');
				networkState = NetworkState.NETWORK_EMPTY;
				readyState = ReadyState.HAVE_NOTHING;
				_seeking = false;
			}
			
			err = null;
			autoPlay = true;
			
			networkState = NetworkState.NETWORK_NO_SOURCE;
			if (src == '') return;
			
			loadFlag = true;
			networkState = NetworkState.NETWORK_LOADING;
			c('flashEvent', 'loadstart');
			_currentSrc = src;
			tempo.load(src);
		}
		
		public function canPlayType(type:String):String {
			var canPlay:Boolean = false;
			if (!canPlay) canPlay = rtP.isValidMIME(type);
			if (!canPlay) canPlay = sndP.isValidMIME(type);
			if (canPlay) return 'probably';
			
			if (type == 'application/octet-stream') return 'probably';
			// if type is sketchy return 'maybe' otherwise blank
			return '';
		}
		
		public function play():void {
			if (networkState == NetworkState.NETWORK_EMPTY) {
				load();
			}
			
			if (ended) {
				tempo.seek(0);
				c('flashEvent', 'timeupdate');
			}
			
			if (tempo.paused) {
				tempo.pause(false);
				c('flashEvent', 'play');
				if (readyState == ReadyState.HAVE_NOTHING || readyState == ReadyState.HAVE_METADATA || readyState == ReadyState.HAVE_CURRENT_DATA) {
					c('flashEvent', 'waiting');
				} else if (readyState == ReadyState.HAVE_FUTURE_DATA || readyState == ReadyState.HAVE_ENOUGH_DATA) {
					c('flashEvent', 'playing');
				}
				autoPlay = false;
			}
		}
		
		public function pause():void {
			if (networkState == NetworkState.NETWORK_EMPTY) {
				load();
			}
			
			autoPlay = false;
			if (!tempo.paused) {
				tempo.pause(true);
				c('flashEvent', 'timeupdate');
				c('flashEvent', 'pause');
			}
		}
		
		public function requestFullscreen():void {
			if (!vidFullScreen) vidFullScreen = new Video();
			vidFullScreen.width = vidScreen.videoWidth;
			vidFullScreen.height = vidScreen.videoHeight;
			vidFullScreen.x = 10000;
			vidFullScreen.y = 10000;
			stage.addChild(vidFullScreen);
			
			rtP.video = vidFullScreen;
			
			var fullScreenRect:Rectangle = new Rectangle(vidFullScreen.x, vidFullScreen.y, vidFullScreen.width, vidFullScreen.height);
			var rectAspectRatio:Number = fullScreenRect.width / fullScreenRect.height;
			var screenAspectRatio:Number = stage.fullScreenWidth / stage.fullScreenHeight;
			
			if (rectAspectRatio > screenAspectRatio) {
				var newHeight:Number = fullScreenRect.width / screenAspectRatio;
				fullScreenRect.y -= ((newHeight - fullScreenRect.height) / 2);
				fullScreenRect.height = newHeight;
			} else if (rectAspectRatio < screenAspectRatio) {
				var newWidth:Number = fullScreenRect.height * screenAspectRatio;
				fullScreenRect.x -= ((newWidth - fullScreenRect.width) / 2);
				fullScreenRect.width = newWidth;
			}
			
			stage.fullScreenSourceRect = fullScreenRect;
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		public function exitFullscreen():void {
			stage.displayState = StageDisplayState.NORMAL;
		}
		
		protected function fullScreenHandler(e:FullScreenEvent):void {
			if (!e.fullScreen) {
				// On return from full screen
				if (vidFullScreen) {
					rtP.video = vidScreen;
					
					stage.removeChild(vidFullScreen);
					stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
				}
			} else {
				// On full screen
			}
		};
		
		protected function isEmpty(str:String):Boolean {
			if (!str) return true;
			return !str.length;
		}
		
		/*override protected function metaDataHandler(e:MetaDataEvent):void {
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
		}*/
	}
}