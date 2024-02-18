/**
* ...
* @author Default
* @version 0.1
*/

package com.coursevector.tempo.view.components {
	
	import fl.events.SliderEvent; 
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.media.Video;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.FullScreenEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;

	import com.coursevector.tempo.view.events.PlayerEvent;

	public class Player extends Sprite {
		
		// Properties
		private var _time:int;
		private var _time2:int;
		private var _timeTotal:int;
		private var _title:String = "";
		private var _artist:String = "";
		private var _album:String = "";
		private var _status:String = "";
		private var _repeat:String;
		private var _scaleMode:String;
		private var _loadProgress:Object;
		
		// Values
		private var objMetaData:Object;
		private var currentVolume:Number = 1;
		private var screenWidth:Number;
		private var screenHeight:Number;
		private var screenX:Number;
		private var screenY:Number;
		private var child:DisplayObject;
		private var mcSkin:DisplayObjectContainer;
		private var isSeeking:Boolean = false;
		private var isFullScreen:Boolean = false;
		
		// Skin Items
		private var vidFullScreen:Video;
		private var vidScreen:Video;
		private var btnPrev:DisplayObject;
		private var btnPlay:DisplayObject;
		private var btnNext:DisplayObject;
		private var btnStop:DisplayObject;
		private var btnPause:DisplayObject;
		private var btnFullScreen:DisplayObject;
		private var mcShuffle:DisplayObject;
		private var mcRepeat:DisplayObject;
		private var mcMute:DisplayObject;
		private var mcPausePlay:DisplayObject;
		private var txtTitle:DisplayObject; // fl.controls::Label / TextField
		private var txtArtist:DisplayObject;
		private var txtAlbum:DisplayObject;
		private var txtTime:DisplayObject;
		private var txtTime2:DisplayObject;
		private var txtTimeSeek:DisplayObject;
		private var txtTimeTotal:DisplayObject;
		private var load_bar:DisplayObject; //ProgressBar
		private var volume_slider:DisplayObject; // fl.controls::Slider
		private var playhead_slider:DisplayObject; // fl.controls::Slider
		
		public function Player():void { }
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function set album(str:String):void {
			_album = str;
			setText(txtAlbum, _album);
		}
		
		public function set artist(str:String):void {
			_artist = str;
			setText(txtArtist, _artist);
		}
		
		public function set loadProgress(obj:Object):void {
			_loadProgress = obj;
			if (load_bar) load_bar.setProgress(_loadProgress.loaded, _loadProgress.total);
		}
		
		public function set mute(b:Boolean):void {
			if(b) {
				setFrame(mcMute, 2);
				volume_slider.value = 0;
			} else {
				setFrame(mcMute);
				volume_slider.value = currentVolume;
			}
		}
		
		public function set repeat(str:String):void {
			_repeat = str;
			
			switch(_repeat) {
				case PlayerEvent.REPEAT_ALL :
					setFrame(mcRepeat);
					break;
				case PlayerEvent.REPEAT_TRACK :
					setFrame(mcRepeat, 2);
					break;
				case PlayerEvent.REPEAT_NONE :
					// Skip PlayerEvent.REPEAT_NONE
					dispatchEvent(new Event(PlayerEvent.REPEAT));
			}
		}
		
		public function set scaleMode(str:String):void {
			switch(str) {
				case PlayerEvent.MAINTAIN_ASPECT_RATIO :
				case PlayerEvent.EXACT_FIT :
				case PlayerEvent.NO_SCALE :
					break;
				default :
					return;
			}
			
			_scaleMode = str;
			autoSizeVideo();
		}
		public function get scaleMode():String {
			return _scaleMode;
		}
		
		public function set shuffle(b:Boolean):void {
			if (mcShuffle) setFrame(mcShuffle, b ? 2 : 1);
		}
		
		// Countup
		public function set time(n:int):void {
			_time = n != 0 ? n / 1000 : 0;
			setText(txtTime, convertTime(_time));
		}
		
		// Countdown
		public function set time2(n:int):void {
			_time2 = n > 0 ? n / 1000 : 0;
			setText(txtTime2, "-" + convertTime(_time2));
		}
		
		public function set timeTotal(n:int):void {
			_timeTotal = n != 0 ? n / 1000 : 0;
			setText(txtTimeTotal, convertTime(_timeTotal));
		}
		
		public function set title(str:String):void {
			_title = str;
			setText(txtTitle, _title);
		}
		
		public function set trackPosition(n:Number):void {
			if (playhead_slider) {
				if (getQualifiedClassName(playhead_slider) != "fl.controls::Slider") {
					playhead_slider.value = n;
				} else {
					// Is standard slider
					if (!isSeeking) playhead_slider.value = n;
				}
			}
		}
		public function get trackPosition():Number {
			return (playhead_slider) ? playhead_slider.value : 0;
		}
		
		public function get video():Video {
			if (vidScreen) {
				return isFullScreen ? vidFullScreen : vidScreen;
			} else {
				return null;
			}
		}
		
		public function set volume(n:Number):void {
			currentVolume = n;
			if (volume_slider) volume_slider.value = n;
		}
		public function get volume():Number {
			return currentVolume;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function getStatus():String {
			return _status;
		}
		
		public function goFullScreen():void {
			var s:Stage = mcSkin.stage;
			isFullScreen = true;
			
			if(!vidFullScreen) vidFullScreen = new Video();
			vidFullScreen.width = vidScreen.videoWidth;
			vidFullScreen.height = vidScreen.videoHeight;
			vidFullScreen.x = 10000;
			vidFullScreen.y = 10000;
			s.addChild(vidFullScreen);

			dispatchEvent(new Event(PlayerEvent.SET_SCREEN));
			
			var fullScreenRect:Rectangle = new Rectangle(vidFullScreen.x, vidFullScreen.y, vidFullScreen.width, vidFullScreen.height);
			var rectAspectRatio:Number = fullScreenRect.width / fullScreenRect.height;
			var screenAspectRatio:Number = s.fullScreenWidth / s.fullScreenHeight;
			
			if (rectAspectRatio > screenAspectRatio) {
				var newHeight:Number = fullScreenRect.width / screenAspectRatio;
				fullScreenRect.y -= ((newHeight - fullScreenRect.height) / 2);
				fullScreenRect.height = newHeight;
			} else if (rectAspectRatio < screenAspectRatio) {
				var newWidth:Number = fullScreenRect.height * screenAspectRatio;
				fullScreenRect.x -= ((newWidth - fullScreenRect.width) / 2);
				fullScreenRect.width = newWidth;
			}
			
			s.fullScreenSourceRect = fullScreenRect;
			s.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
			s.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		public function goNormalScreen():void {
			mcSkin.stage.displayState = StageDisplayState.NORMAL;
		}
		
		public function setAudMetaData(obj:Object):void {
			objMetaData = obj;
			if(objMetaData) {
				var str:String = objMetaData.songname || objMetaData.TIT2 || null;
				if (str) title = str;
				str = objMetaData.artist || objMetaData.TPE1 || null;
				if (str) artist = str;
				str = objMetaData.album || objMetaData.TOAL || null;
				if (str) album = str;
			}
		}
		
		public function setStatus(stat:String = null):void {
			_status = stat;
			
			switch(_status) {
				case PlayerEvent.PLAY:
					autoSizeVideo();
					setFrame(mcPausePlay, 2);
					break;
				case PlayerEvent.PAUSE:
					setFrame(mcPausePlay);
					break;
				case PlayerEvent.STOP:
					time = 0;
					setFrame(mcPausePlay);
					break;
				default:
					// Initialize
					time = 0;
					setFrame(mcPausePlay);
			}
		}
		
		public function setVidMetaData(obj:Object):void {
			objMetaData = obj;
			autoSizeVideo();
		}
		
		public function start():void {
			autoSizeVideo();
		}
		
		public function startUp(mc:DisplayObjectContainer):void {
			mcSkin = mc;
			
			if (hasChild('btnNext')) initButton('btnNext');
			if (hasChild('btnPrev')) initButton('btnPrev');
			if (hasChild('btnPlay')) initButton('btnPlay');
			if (hasChild('btnStop')) initButton('btnStop');
			if (hasChild('btnPause')) initButton('btnPause');
			if (hasChild('btnFullScreen')) initButton('btnFullScreen');
			
			if (hasChild('mcShuffle')) {
				initSetting('mcShuffle');
				setFrame(mcShuffle);
			}
			
			if (hasChild('mcRepeat')) {
				initSetting('mcRepeat');
				if (_repeat == PlayerEvent.REPEAT_ALL) {
					setFrame(mcRepeat);
				} else {
					setFrame(mcRepeat, 2);
				}
			}
			
			if (hasChild('mcMute')) {
				initSetting('mcMute');
				setFrame(mcMute);
			}
			
			if (hasChild('mcPausePlay')) {
				initSetting('mcPausePlay');
				setFrame(mcPausePlay);
			}
			
			if (hasChild('volume_slider')) {
				volume_slider = child;
				volume_slider.maximum = 1;
				volume_slider.minimum = 0;
				volume_slider.snapInterval = 0.01;
				volume_slider.liveDragging = true;
				volume_slider.value = currentVolume;
				volume_slider.addEventListener(SliderEvent.CHANGE, volumeHandler);
			}
			
			if (hasChild('playhead_slider')) {
				playhead_slider = child;
				playhead_slider.maximum = 1;
				playhead_slider.minimum = 0;
				playhead_slider.snapInterval = 0.01;
				playhead_slider.value = 0;
				playhead_slider.addEventListener(SliderEvent.THUMB_PRESS, playheadHandler);
				playhead_slider.addEventListener(SliderEvent.THUMB_RELEASE, playheadHandler);
				playhead_slider.addEventListener(SliderEvent.THUMB_DRAG, playheadHandler);
				playhead_slider.addEventListener(SliderEvent.CHANGE, playheadHandler);
			}
			
			if (hasChild('load_bar')) {
				load_bar = child;
				load_bar.mode = "manual";
				if(_loadProgress) loadProgress = _loadProgress;
			}
			
			if (hasChild('txtTitle')) {
				initText('txtTitle');
				title = _title;
			}
			
			if (hasChild('txtArtist')) {
				initText('txtArtist');
				artist = _artist;
			}
			
			if (hasChild('txtAlbum')) {
				initText('txtAlbum');
				album = _album;
			}
			
			if (hasChild('txtTime')) {
				initText('txtTime');
			} else if (hasChild('txtTimeUp')) {
				initText('txtTime');
			}
			
			if (hasChild('txtTimeDown')) initText('txtTime2');
			if (hasChild('txtTimeSeek')) initText('txtTimeSeek');
			if (hasChild('txtTimeTotal')) initText('txtTimeTotal');
			
			if (hasChild('vidScreen')) {
				vidScreen = child as Video;
				screenWidth = vidScreen.width;
				screenHeight = vidScreen.height;
				screenX = vidScreen.x;
				screenY = vidScreen.y;
				dispatchEvent(new Event(PlayerEvent.SET_SCREEN));
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function autoSizeVideo():void {
			var v:Video = vidScreen;
			if(v) {
				var vidW:int = v.videoWidth;
				var vidH:int = v.videoHeight;
				switch (_scaleMode) {
					case PlayerEvent.NO_SCALE :
						v.width = vidW;
						v.height = vidH;
						v.x = screenX;
						v.y = screenY;
						break;
					case PlayerEvent.EXACT_FIT :
						v.width = screenWidth;
						v.height = screenHeight;
						v.x = screenX;
						v.y = screenY;
						break;
					case PlayerEvent.MAINTAIN_ASPECT_RATIO :
					default:
						var newWidth:Number = vidW * screenHeight / vidH;
						var newHeight:Number = vidH * screenWidth / vidW;
						if (newHeight < screenHeight) {
							v.width = screenWidth;
							v.height = newHeight;
						} else if (newWidth < screenWidth) {
							v.width = newWidth;
							v.height = screenHeight;
						} else {
							v.width = screenWidth;
							v.height = screenHeight;
						}
						
						v.x = screenX + ((screenWidth - v.width) / 2);
						v.y = screenY + ((screenHeight - v.height) / 2);
				}
			}
		}
		
		private function controlClickHandler(e:Event):void {
			switch(e.currentTarget as DisplayObject) {
				case mcPausePlay:
					if (_status != null) {
						switch(_status) {
							case PlayerEvent.PLAY :
								setStatus(PlayerEvent.PAUSE);
								dispatchEvent(new Event(PlayerEvent.PAUSE));
								break;
							case PlayerEvent.PAUSE :
							case PlayerEvent.STOP :
							default :
								setStatus(PlayerEvent.PLAY);
								dispatchEvent(new Event(PlayerEvent.PLAY));
								break;
						}
					}
					break;
				case mcRepeat:
					dispatchEvent(new Event(PlayerEvent.REPEAT));
					break;
				case mcShuffle:
					dispatchEvent(new Event(PlayerEvent.SHUFFLE));
					break;
				case mcMute:
					dispatchEvent(new Event(PlayerEvent.MUTE));
					break;
				case btnNext:
					dispatchEvent(new Event(PlayerEvent.NEXT));
					break;
				case btnPrev:
					dispatchEvent(new Event(PlayerEvent.PREVIOUS));
					break;
				case btnPlay:
					if(_status != null) {
						setStatus(PlayerEvent.PLAY);
						dispatchEvent(new Event(PlayerEvent.PLAY));
					}
					break;
				case btnPause:
					if(_status != null) {
						if(_status == PlayerEvent.PAUSE) {
							setStatus(PlayerEvent.PLAY);
						} else {
							setStatus(PlayerEvent.PAUSE);
						}
						dispatchEvent(new Event(PlayerEvent.PAUSE));
					}
					break;
				case btnStop:
					if(_status != null) {
						setStatus(PlayerEvent.STOP);
						dispatchEvent(new Event(PlayerEvent.STOP));
					}
					break;
				case btnFullScreen:
					if (vidScreen) {
						goFullScreen();
					} else {
						trace("Player::btnFullScreen - Error : Must have a video screen");
					}
					break;
			}
		}
		
		private function convertTime(n:Number):String {
			var m:String = int(n / 60).toString();
			var s:String = int(int(n) % 60).toString();
			if (int(s) < 10) s = "0" + s;
			return m + ":" + s;
		}
		
		private function fullScreenHandler(e:FullScreenEvent):void {
			if (!e.fullScreen) {
				// On return from full screen
				isFullScreen = false;
				if(vidFullScreen) {
					dispatchEvent(new Event(PlayerEvent.SET_SCREEN));
					
					mcSkin.stage.removeChild(vidFullScreen);
					mcSkin.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
				}
			} else {
				// On full screen
			}
		};
		
		private function hasChild(s:String):Boolean {
			child = mcSkin.getChildByName(s);
			if (child != null) return true;
			return false;
		}
		
		private function initButton(str:String):void {
			this[str] = child;
			this[str].addEventListener(MouseEvent.CLICK, controlClickHandler);
		}
		
		private function initSetting(str:String):void {
			this[str] = child;
			if (getQualifiedClassName(this[str]) == "fl.controls::Button") {
				if(this[str].toggle) {
					this[str].addEventListener(Event.CHANGE, controlClickHandler);
				} else {
					this[str].addEventListener(MouseEvent.CLICK, controlClickHandler);
				}
			} else {
				this[str].mouseChildren = false;
				this[str].addEventListener(MouseEvent.CLICK, controlClickHandler);
			}
		}
		
		private function initText(str:String):void {
			this[str] = child;
			this[str].autoSize = TextFieldAutoSize.LEFT;
		}
		
		private function playheadHandler(e:SliderEvent):void {
			switch(e.type) {
				case SliderEvent.THUMB_PRESS :
					isSeeking = true;
					break;
				case SliderEvent.THUMB_RELEASE :
					isSeeking = false;
					break;
				case SliderEvent.THUMB_DRAG : 
					setText(txtTimeSeek, convertTime(_timeTotal * e.value));
					break;
				case SliderEvent.CHANGE :
					dispatchEvent(new Event(PlayerEvent.SEEK));
					break;
			}
		}
		
		private function setFrame(mc:DisplayObject = null, frame:uint = 1):void {
			if(mc) {
				if (mc is MovieClip) {
					mc.gotoAndStop(frame);
				}
			}
		}
		
		private function setText(txt:DisplayObject = null, str:String = ""):void {
			if (txt) {
				txt.text = str;
				txt.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private function volumeHandler(e:Event):void {
			currentVolume = volume_slider.value;
			dispatchEvent(new Event(PlayerEvent.VOLUME));
		}
	}
}