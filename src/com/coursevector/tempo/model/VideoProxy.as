////////////////////////////////////////////////////////////////////////////////
//
//  COURSE VECTOR
//  Copyright 2008 Course Vector
//  All Rights Reserved.
//
//  NOTICE: Course Vector permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
/**
 * Facade of the NetStream and NetConnection classes
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

package com.coursevector.tempo.model {
	
    import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.interfaces.IMediaProxy;
	import com.coursevector.tempo.interfaces.IVideoProxy;
	
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.TimerEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	public class VideoProxy extends Proxy implements IProxy, IMediaProxy, IVideoProxy {
		/*
		// VIDEO //
		MetaData
		canSeekToEnd
		cuePoints
		audiocodecid
		audiodelay
		audiodatarate
		videocodecid
		framerate
		videodatarate
		height - Older version of encode
		width - Older version of encode
		duration - Older version of encode
		
		  Events
		onMetaData
		onPlayStatus
		onCuePoint
		ioError
		asyncError
		*/
		public static const NAME:String = 'VideoProxy';
		
		private var _autoScale:Boolean = false;
		private var _buffer:Number = 0.1;
		private var _pause:Boolean = false;
		private var _loadCurrent:Number;
		private var _loadTotal:Number;
		private var _metaData:Object;
		private var _volume:Number = 1;
		private var fileTypes:Array = ["flv","f4v","f4p","f4b","f4a","3gp","3g2","mov","mp4","m4v","m4a","p4v"];
		private var isReadyToPlay:Boolean = false;
		private var isPlaying:Boolean = false;
		private var isMute:Boolean = false;
		private var loadTimer:Timer = new Timer(10);
		private var ns:NetStream;
		private var playTimer:Timer = new Timer(10);
		private var strURL:String;
		private var strExt:String;
		private var vid:Video;
		private var sendOnce:Boolean = false;
		
		public function VideoProxy() {
            super(NAME);
			
			playTimer.addEventListener(TimerEvent.TIMER, onPlayTimer);
			loadTimer.addEventListener(TimerEvent.TIMER, onLoadTimer);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function set autoScale(b:Boolean):void { _autoScale = b }
		public function get autoScale():Boolean { return _autoScale }
		
		// In seconds
		public function set buffer(n:int):void {
			if(n <= 0) n = 0.1;
			_buffer = n;
		}
		public function get buffer():int { return _buffer }
		
		public function get currentPercent():uint {	return ns ? uint(100 * ((ns.time * 1000) / getEstimatedLength())) : 0 }
		
		public function get isPause():Boolean { return _pause }
		
		public function get loadCurrent():Number { return _loadCurrent ? _loadCurrent : 0 }
		
		public function get loadTotal():Number { return _loadTotal ? _loadTotal : 0 }
		
		public function get metaData():Object { return _metaData }
		
		public function get timeCurrent():Number { return ns ? ns.time * 1000 : 0 }
		
		public function get timeLeft():Number {	return ns ? timeTotal - timeCurrent : 0	}
		
		public function get timeTotal():Number { return getEstimatedLength() }
		
		public function set video(v:Video):void {
			vid = v;
			
			if(ns) vid.attachNetStream(ns);
			
			if(_autoScale && _metaData) {
				vid.width = _metaData.width;
				vid.height = _metaData.height;
			}
		}
		public function get video():Video {	return vid }
		
		public function set volume(n:Number):void {
			_volume = Math.max(0, Math.min(1, n));
			updateVolume();
		}
		public function get volume():Number { return _volume }
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function isValid(str:String):Boolean {
			strExt = str;
			return !(fileTypes.every(checkFileType));
		}
		
		public function load(s:String):void {
			if (s == "" || s == null) {
				trace("VideoProxy::load - Error : Must enter a url to load a file");
				return;
			}
			
			unLoad();
			
			strURL = unescape(s);
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.client = {onMetadata:metaDataHandler};
			ns.bufferTime = _buffer;
			ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			ns.addEventListener("ioError", errorHandler);
			ns.addEventListener("securityError", errorHandler);
			ns.addEventListener("asyncError", errorHandler);
			if(vid) vid.attachNetStream(ns);
			
			loadTimer.start();
			
			// On Load Open
			isReadyToPlay = true;
			sendOnce = false;
			play();
			sendNotification(ApplicationFacade.LOAD_START, {url:strURL, type:"video", time:timeTotal});
		}
		
		public function mute(b:Boolean = true):void {
			isMute = b;
			updateVolume();
		}
		
		public function pause(b:Boolean = true):void {
			_pause = b;
			if (b) {
				isPlaying = false;
				if(ns) ns.pause();
				if(playTimer) playTimer.stop();
			} else {
				isPlaying = true;
				if(ns) ns.resume();
				if(playTimer) playTimer.start();
			}
		}
		
		public function play(pos:int = 0):void {
			if (!isPlaying) {
				if (isReadyToPlay) {
					if(_pause) {
						pause(false);
						return;
					}
					
					ns.play(strURL);
					ns.seek(pos);
					updateVolume();
					isPlaying = true;
					
					playTimer.start();
				}
			}
		}
		
		public function seek(n:Number):void {
			n = Math.max(0, Math.min(getEstimatedLength(), n / 1000));
			ns.seek(n);
			if(_pause) ns.pause();
		}
		
		public function seekPercent(n:Number):void { seek((n * getEstimatedLength()) / 100) }
		
		public function stop(pos:int = 0):void {
			if (isPlaying) {
				if (ns) {
					ns.pause();
					ns.seek(0);
				}
				if (playTimer) playTimer.stop();
				isPlaying = false;
			}
		}
		
		public function unLoad():void {
			stop();
			try {
				if(vid) vid.clear();
				if(ns) ns.close();
			} catch (error:IOError) {
				// Isn't streaming/loading any longer
			}
			_pause = false;
			_metaData = null;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function checkFileType(item:String, idx:int, arr:Array):Boolean {
			return (item != strExt);
		}
		
		private function errorHandler(e:ErrorEvent):void {
			trace("VideoProxy::load - Error: " + e.text);
		}
		
		private function getEstimatedLength():int {
			// If the metadata length is available, use that instead
			//var estLen:int = Math.ceil(sndSong.length / (sndSong.bytesLoaded / sndSong.bytesTotal));
			//return (sndMetaData) ? (sndMetaData.TLEN) ? sndMetaData.TLEN : estLen : estLen;
			return (_metaData) ? _metaData.duration * 1000 : 0;
		}
		
		private function metaDataHandler(o:Object):void {
			_metaData = o;
			if(_autoScale) {
				if (vid) {
					vid.width = o.width;
					vid.height = o.height;
				}
			}
			sendNotification(ApplicationFacade.VIDEO_METADATA, _metaData);
		}
		
		private function onCuePoint(o:Object):void {
			trace("VideoProxy::onCuePoint");
		}
		
		private function onLoadTimer(event:TimerEvent):void {
			try {
				if(ns.bytesLoaded == ns.bytesTotal) {
					isReadyToPlay = true;
					loadTimer.stop();
					sendNotification(ApplicationFacade.LOAD_COMPLETE);
				} else {
					_loadCurrent = ns.bytesLoaded;
					_loadTotal = ns.bytesTotal;
					sendNotification(ApplicationFacade.LOAD_PROGRESS, {loaded:ns.bytesLoaded, total:ns.bytesTotal});
				}
			} catch (error:Error) {
				// Ignore this error
			}
		}
		
		private function onNetStatus(e:NetStatusEvent):void {
			//trace("VideoProxy::onNetStatus : " + e.info.code);
			try {
				switch (e.info.code) {
					case "NetStream.Play.Start":
						// Video started
						play();
						break;
					case "NetStream.Play.Stop":
						stop();
						sendNotification(ApplicationFacade.PLAY_COMPLETE);
						sendNotification(ApplicationFacade.NEXT);
						break;
					case "NetStream.Play.StreamNotFound":
						stop();
						break;
					case "NetStream.Play.Failed":
						stop();
						break;
						
						
					case "NetStream.Pause.Notify":
						// Paused
						break;
					case "NetStream.Unpause.Notify":
						// Resumed
						break;
						
						
					case "NetStream.Buffer.Empty":
						//pause(true);
						break;
					case "NetStream.Buffer.Full":
						//pause(false);
						break;
					case "NetStream.Buffer.Flush":
						// Data has finished streaming, and the remaining buffer will be emptied.
						break;
						
						
					case "NetStream.Seek.Failed":
						// Seek failed
						break;
					case "NetStream.Seek.InvalidTime":
						// Seek to last available time
						seek(e.info.message.details);
						break;
					case "NetStream.Seek.Notify":
						// Seek was successful
						//trace("VideoProxy - onNetStatus: Seek was successful");
						break;
						
						
					case "NetStream.FileStructureInvalid":
						trace("VideoProxy::onNetStatus - Error : The MP4's file structure is invalid");
						break;
					case "NetStream.NoSupportedTrackFound":
						trace("VideoProxy::onNetStatus - Error : The MP4 doesn't contain any supported tracks");
						break;
						
				}
			} catch (error:Error) {
				// Ignore this error
				trace("VideoProxy::onNetStatus - Error : " + error.message);
			}
		}
		
		private function onPlayTimer(event:TimerEvent):void {
			if (!sendOnce && vid) {
				if (vid.videoHeight != 0 && vid.videoWidth != 0) {
					sendNotification(ApplicationFacade.PLAY_START, { type:"video", time:timeTotal } );
					sendOnce = true;
				}
			}
			sendNotification(ApplicationFacade.PLAY_PROGRESS, {percent:currentPercent, elapsed:timeCurrent, remain:timeLeft, total:timeTotal});
		}
		
		private function updateVolume():void {
			if(ns) ns.soundTransform = new SoundTransform(isMute ? 0 : _volume);
		}
	}
}