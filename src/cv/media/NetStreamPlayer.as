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

package cv.media {
	
	import cv.interfaces.IMediaPlayer;
	import cv.events.CuePointEvent;
	import cv.events.MetaDataEvent;
	import cv.events.LoadEvent;
	import cv.events.PlayProgressEvent;
	
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	//--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched everytime a cuepoint in encountered
	 *
	 * @eventType cv.events.CuePointEvent.CUE_POINT
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "cuePoint", type = "cv.events.CuePointEvent")]
	
	/**
	 * Dispatched when the media file has completed loading
	 *
	 * @eventType cv.events.LoadEvent.LOAD_COMPLETE
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "loadComplete", type = "flash.events.Event")]
	
	/**
	 * Dispatched as a media file is loaded
	 *
	 * @eventType cv.events.LoadEvent.LOAD_PROGRESS
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "loadProgress", type = "flash.events.ProgressEvent")]
	
	/**
	 * Dispatched as a media file begins loading
	 *
	 * @eventType cv.events.LoadEvent.LOAD_START
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "loadStart", type = "cv.LoadEvent")]
	
	/**
	 * Dispatched as a media file finishes playing
	 *
	 * @eventType cv.events.PlayProgressEvent.PLAY_COMPLETE
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "playComplete", type = "flash.events.Event")]
	
	/**
	 * Dispatched as a media file is playing
	 *
	 * @eventType cv.events.PlayProgressEvent.PLAY_PROGRESS
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name="playProgress", type="cv.events.PlayProgressEvent")]
	
	/**
	 * Dispatched once as a media file first begins to play
	 *
	 * @eventType cv.events.PlayProgressEvent.PLAY_START
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "playStart", type = "flash.events.Event")]
	
	/**
	 * Dispatched when isPause or isPlaying has updated.
	 *
	 * @eventType cv.events.PlayProgressEvent.STATUS
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "status", type = "flash.events.Event")]
	
	/**
	 * Dispatched as metadata is receieved from the media playing
	 *
	 * @eventType cv.events.MetaDataEvent.VIDEO_METADATA
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "videoMetadata", type = "cv.events.MetaDataEvent")]
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * <h3>Version:</h3> 2.1.0<br>
	 * <h3>Date:</h3> 1/28/2009<br>
	 * <h3>Updates At:</h3> http://blog.coursevector.com/tempolite<br>
	 * <br>
	 * The NetStreamPlayer class is a facade for controlling loading, and playing
	 * of video, streaming video and M4A files within Flash. It intelligently handles pausing, mute and
	 * loading.
	 * 
	 * Note: Sometimes playhead won't move on videos, this is because there is no 
	 * metadata describing it's duration. If this occurs, there is no way to
	 * calculate how long a video is, so it stops the playhead from moving.
     *
	 * @see cv.interfaces.IMediaPlayer
     */
	public class NetStreamPlayer extends EventDispatcher implements IMediaPlayer {
		
		/**
         * The current version
		 */
		public static const VERSION:String = "2.1.0";
		
		public static const NETSTREAM:String = "netstream";
		public var debug:Boolean = false;
		
		private var _autoScale:Boolean = false;
		private var _autoStart:Boolean;
		private var _buffer:Number = 0.1;
		private var _isPause:Boolean = false;
		private var _loadCurrent:Number;
		private var _loadTotal:Number;
		private var _metaData:Object;
		private var _volume:Number = 1;
		private var _leftToLeft:Number = 1;
		private var _leftToRight:Number = 0;
		private var _rightToLeft:Number = 0;
		private var _rightToRight:Number = 1;
		private var _pan:Number = 0;
		private var fileTypes:Array = ["flv","f4v","f4p","f4b","f4a","3gp","3g2","mov","mp4","m4v","m4a","p4v"];
		private var _isReadyToPlay:Boolean = false;
		private var _isPlaying:Boolean = false;
		private var _mute:Boolean = false;
		private var loadTimer:Timer = new Timer(10);
		private var ns:NetStream;
		private var playTimer:Timer = new Timer(10);
		private var strURL:String;
		private var strExt:String;
		private var vid:Video;
		private var sendOnce:Boolean = false;
		private var _streamHost:String = null;
		private var nc:NetConnection;
		private var _encoding:uint = 0;
		private var _bwInKbps:int;
		
		public function NetStreamPlayer() {
			playTimer.addEventListener(TimerEvent.TIMER, onPlayTimer);
			loadTimer.addEventListener(TimerEvent.TIMER, onLoadTimer);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/** 
		 * Gets or sets whether the video object will be scaled to the metadata given
		 * for video dimensions.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get autoScale():Boolean { return _autoScale }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set autoScale(b:Boolean):void { _autoScale = b }
		
		/** 
		 * Gets or sets whether media will play automatically once loaded.
		 * 
		 * @default true
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get autoStart():Boolean { return _autoStart	}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set autoStart(b:Boolean):void {	_autoStart = b }
		
		
		/** 
		 * Gets or sets how long the NetStreamPlayer should buffer the video before playing, in seconds.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get buffer():int { return _buffer }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set buffer(n:int):void {
			if(n <= 0) n = 0.1;
			_buffer = n;
		}
		
		/** 
		 * Gets the current play progress in terms of percent
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get currentPercent():uint {	return ns ? uint(100 * ((ns.time * 1000) / getEstimatedLength())) : 0 }
		
		/** 
		 * If NetStreamPlayer is currently paused.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get isPause():Boolean { return _isPause }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set isPause(value:Boolean):void {
			_isPause = value;
			dispatchEvent(new Event(PlayProgressEvent.STATUS));
		}
		
		/** 
		 * If NetStreamPlayer is currently playing.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get isPlaying():Boolean { return _isPlaying }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set isPlaying(value:Boolean):void {
			_isPlaying = value;
			dispatchEvent(new Event(PlayProgressEvent.STATUS));
		}
		
		/** 
		 * If NetStreamPlayer is ready to play.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get isReadyToPlay():Boolean { return _isReadyToPlay }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set isReadyToPlay(value:Boolean):void {
			_isReadyToPlay = value;
			dispatchEvent(new Event(PlayProgressEvent.STATUS));
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left input is played in the left speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get leftToLeft():Number { return _leftToLeft }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set leftToLeft(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_leftToLeft = v;
			updateSoundTransform();
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left input is played in the right speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get leftToRight():Number { return _leftToRight }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set leftToRight(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_leftToRight = v;
			updateSoundTransform();
		}
		
		/** 
		 * Gets the current load progress in terms of bytes
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get loadCurrent():Number { return _loadCurrent ? _loadCurrent : 0 }
		
		/** 
		 * Gets the total size to be loaded in terms of bytes
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get loadTotal():Number { return _loadTotal ? _loadTotal : 0 }
		
		/** 
		 * Gets the metadata if available for the currently playing audio file
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get metaData():Object { return _metaData }
		
		/** 
		 * Gets or sets the object encodeing for use with streaming servers.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get objectEncoding():uint { return _encoding }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set objectEncoding(value:uint):void { if(value == 0 || value == 3) _encoding = value }
		
		/** 
		 * The left-to-right panning of the sound, ranging from -1 (full pan left) to 1 (full pan right). 
		 * A value of 0 represents no panning (balanced center between right and left). 
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get pan():Number { return _pan }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set pan(n:Number):void {
			var v:Number = Math.max(-1, Math.min(1, n));
			_pan = v;
			if (ns) {
				var transform:SoundTransform = ns.soundTransform;
				transform.pan = _pan;
				ns.soundTransform = transform;
				
				_leftToLeft = transform.leftToLeft;
				_leftToRight = transform.leftToRight;
				_rightToLeft = transform.rightToLeft;
				_rightToRight = transform.rightToRight;
			}
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right input is played in the left speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get rightToLeft():Number { return _rightToLeft }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set rightToLeft(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_rightToLeft = v;
			updateSoundTransform();
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right input is played in the right speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get rightToRight():Number { return _rightToRight }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set rightToRight(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			_rightToRight = v;
			updateSoundTransform();
		}
		
		/** 
		 * Gets or sets the stream host url for use with streaming media.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get streamHost():String { return _streamHost }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set streamHost(value:String):void {	_streamHost = value }
		
		/** 
		 * Gets the elapsed play time in milliseconds
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get timeCurrent():Number { return ns ? ns.time * 1000 : 0 }
		
		/** 
		 * Gets the remaining play time in milliseconds
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get timeLeft():Number {	return ns ? timeTotal - timeCurrent : 0	}
		
		/** 
		 * Gets the total play time in milliseconds
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get timeTotal():Number { return getEstimatedLength() }
		
		/** 
		 * Gets or sets the reference to the display video object.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get video():Video {	return vid }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set video(v:Video):void {
			vid = v;
			
			if(ns) vid.attachNetStream(ns);
			
			if(_autoScale && _metaData) {
				vid.width = _metaData.width;
				vid.height = _metaData.height;
			}
		}
		
		/** 
		 * Gets or sets the current volume, from 0 - 1
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get volume():Number { return _volume }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set volume(n:Number):void {
			_volume = Math.max(0, Math.min(1, n));
			updateSoundTransform();
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Validates if the given filetype is compatible to be played with NetStreamPlayer. 
		 * The acceptable file types are :
		 * <ul>
		 * <li>flv : video/x-flv Flash Video</li>
		 * <li>f4v : video/mp4 	Flash Video</li>
		 * <li>f4p : video/mp4 	Protected Flash Video</li>
		 * <li>f4b : audio/mp4 	Flash Audio Book</li>
		 * <li>f4a : audio/mp4 	Flash Audio</li>
		 * <li>3gp : video/3gpp  audio/3gpp	3GPP for GSM-based Phones</li>
		 * <li>3g2 : video/3gpp  audio/3gpp	3GPP2 for CDMA-based Phones</li>
		 * <li>mov : video/quicktime	QuickTime Movie</li>
		 * <li>mp4 : video/mp4 	H.264 MPEG-4 Video</li>
		 * <li>m4v : video/mp4 	H.264 MPEG-4 Video</li>
		 * <li>m4a : audio/mp4 	Audio-only MPEG-4</li>
		 * <li>p4v : audio/mp4 	Protected H.264 MPEG-4 Video</li>
		 * </ul>
		 * 
		 * @param str	The file extension to be validated
		 * 
		 * @return Boolean of whether the extension was valid or not.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function isValid(str:String):Boolean {
			strExt = str;
			return !(fileTypes.every(checkFileType));
		}
		
		/**
		 * Loads a new file to be played.
		 * 
		 * @param s	The url of the file to be loaded
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function load(s:String, autoStart:Boolean):void {
			if (s == "" || s == null) {
				trace2("NetStreamPlayer::load - Error : Must enter a url to load a file");
				return;
			}
			
			unload();
			strURL = unescape(s);
			_autoStart = autoStart;
			
			nc = new NetConnection();
			nc.client = { onMetaData:onMetaData, onCuePoint:onCuePoint, onBWDone:onBWDone };
			nc.addEventListener("netStatus", netStatusHandler);
			nc.addEventListener("ioError", errorHandler);
			nc.addEventListener("securityError", errorHandler);
			nc.addEventListener("asyncError", errorHandler);
			nc.objectEncoding = _encoding;
			nc.connect(_streamHost);
		}
		
		/**
		 * Controls the mute of the media
		 * 
		 * @default true
		 * 
		 * @param b	Whether to mute or not
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function mute(b:Boolean = true):void {
			_mute = b;
			updateSoundTransform();
		}
		
		/**
		 * Controls the pause of the media
		 * 
		 * @default true
		 * 
		 * @param b	Whether to pause or not
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function pause(b:Boolean = true):void {
			_isPause = b;
			isPlaying = !b;
			
			if (b) {
				if(ns) ns.pause();
				playTimer.stop();
			} else {
				if(ns) ns.resume();
				playTimer.start();
			}
			
			dispatchEvent(new Event(Event.CHANGE));
			updateProgress();
		}
		
		/**
		 * Plays the media, starting at the given position.
		 * 
		 * @default 0
		 * 
		 * @param pos	Position to play from
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function play(pos:int = 0):void {
			if (!isPlaying) {
				if (isReadyToPlay) {
					if(isPause) {
						pause(false);
						return;
					} else {
						ns.play(strURL);
						ns.seek(pos);
						updateSoundTransform();
						isPlaying = true;
						playTimer.start();
					}
				}
			}
		}
		
		/*public function subscribe(value:String):void {
			nc.call("FCSubscribe", null, value);
		}*/
		
		/**
		 * Seeks to time given in the media.
		 * 
		 * @param n	Seconds into the media to seek to
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seek(n:Number):void {
			n = Math.max(0, Math.min(getEstimatedLength(), n / 1000));
			ns.seek(n);
			if(isPause || !isPlaying) ns.pause();
		}
		
		/**
		 * Seeks to the given percent in the media
		 * 
		 * @param n	Percent to seek to
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seekPercent(n:Number):void { seek((n * getEstimatedLength()) / 100) }
		
		/**
		 * Stops the media at the specified position. Sets the position given as the pause position.
		 * 
		 * @default 0
		 * 
		 * @param pos	Position to stop at
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function stop(pos:int = 0):void {
			if (isPlaying) {
				if (ns) {
					ns.pause();
					ns.seek(0);
				}
				playTimer.stop();
				isPlaying = false;
			}
		}
		
		/**
		 * Stops the media, closes the NetConnetion or NetStream, and resets the metadata.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function unload():void {
			stop();
			try {
				if (vid) vid.clear();
				if (_streamHost != null && _streamHost) {
					if(nc) nc.close();
				} else {
					if (ns) ns.close();
				}
			} catch (error:IOError) {
				// Isn't streaming/loading any longer
			}
			_isPause = false;
			_isPlaying = false;
			isReadyToPlay = false;
			_metaData = null;
			ns = null;
			nc = null;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function checkFileType(item:String, idx:int, arr:Array):Boolean {
			return (item != strExt);
		}
		
		private function createStream():void {
			ns = new NetStream(nc);
			ns.client = {onMetaData:onMetaData, onCuePoint:onCuePoint, onBWDone:onBWDone};
			ns.bufferTime = _buffer;
			ns.addEventListener("netStatus", netStatusHandler);
			ns.addEventListener("ioError", errorHandler);
			ns.addEventListener("securityError", errorHandler);
			ns.addEventListener("asyncError", errorHandler);
			if(vid) vid.attachNetStream(ns);
			
			loadTimer.start();
			
			// On Load Open
			isReadyToPlay = true;
			sendOnce = false;
			play();
			dispatchEvent(new LoadEvent(LoadEvent.LOAD_START, false, false, strURL, NETSTREAM, timeTotal));
		}
		
		private function errorHandler(e:ErrorEvent):void {
			trace2("NetStreamPlayer::load - " + e.type + " : " + e.text);
		}
		
		private function getEstimatedLength():int {
			return (_metaData) ? _metaData.duration * 1000 : 0;
		}
		
		/*
		 * Possible NetClient Events
		 * 
		 * onImageData(param1:Object)
		 * onLastSecond(param1:Object)
		 * onCaption(param1:String, param2:Number)
		 * onMetaData(param1:Object)
		 * onPlayStatus(param1:Object)
		 * onBWCheck(... args)
		 * onCaptionInfo(param1:Object)
		 * onBWDone(... args)
		 * onTextData(param1:Object)
		 * RtmpSampleAccess(param1:Object)
		 * onCuePoint(param1:Object)
		 * onFCSubscribe(param1:Object)
		 */
		
		private function onBWDone(bwInKbps:*):void {
			if (bwInKbps) {
				_bwInKbps = bwInKbps as int;
				//dispatchEvent(new BandWidthEvent(BandWidthEvent.BAND_WIDTH, false, false, _bwInKbps, undefined)); // last prop is latency
			}
		}
		
		/*
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
		*/
		private function onMetaData(o:Object):void {
			_metaData = o;
			
			if(_autoScale) {
				if (vid) {
					vid.width = o.width;
					vid.height = o.height;
				}
			}
			
			dispatchEvent(new MetaDataEvent(MetaDataEvent.VIDEO_METADATA, false, false, _metaData));
		}
		
		/*
		{name, parameters, time, type}
		name - The name given to the cue point when it was embedded in the video file. 
		parameters - A associative array of name/value pair strings specified for this cue point. Any valid string can be used for the parameter name or value. 
		time - The time in seconds at which the cue point occurred in the video file during playback. 
		type - The type of cue point that was reached, either navigation or event. 
		*/
		private function onCuePoint(o:Object):void {
			dispatchEvent(new CuePointEvent(CuePointEvent.CUE_POINT, false, false, o));
		}
		
		private function onLoadTimer(event:TimerEvent):void {
			try {
				if(ns.bytesLoaded == ns.bytesTotal) {
					isReadyToPlay = true;
					loadTimer.stop();
					dispatchEvent(new Event(LoadEvent.LOAD_COMPLETE));
				} else {
					_loadCurrent = ns.bytesLoaded;
					_loadTotal = ns.bytesTotal;
					dispatchEvent(new ProgressEvent(LoadEvent.LOAD_PROGRESS, false, false, ns.bytesLoaded, ns.bytesTotal));
				}
			} catch (error:Error) {
				// Ignore this error
			}
		}
		
		private function netStatusHandler(e:NetStatusEvent):void {
			trace2("NetStreamPlayer::netStatusHandler : " + e.info.code);
			try {
				switch (e.info.code) {
					/* Errors */
					case "NetStream.Failed":
						//Flash Media Server only. An error has occurred for a reason other than those listed in other event codes. 
						trace2("NetStreamPlayer::netStatusHandler - Error : An unknown error has occurred. (" + e.info.code + ")");
						break;
					/*case "NetStream.Publish.BadName":
						//Attempt to publish a stream which is already being published by someone else.
						break;*/
					case "NetStream.Play.Failed":
						trace2("NetStreamPlayer::netStatusHandler - Error : An error has occurred in playback. (" + e.info.code + ")");
						stop();
						break;
					case "NetStream.Play.StreamNotFound":
					case "NetConnection.Connect.Rejected":
					case "NetConnection.Connect.Failed":
						stop();
						trace2("NetStreamPlayer::netStatusHandler - Error : File/Stream not found. (" + e.info.code + ")");
						break;
					/*case "NetStream.Record.NoAccess":
						//Attempt to record a stream that is still playing or the client has no access right.
						break;
					case "NetStream.Record.Failed":
						//An attempt to record a stream failed.
						break;
					case "NetStream.Seek.Failed":
						// Seek failed
						break;*/
					case "NetStream.Seek.InvalidTime":
						// Seek to last available time
						seek(e.info.message.details);
						break;
					/*case "NetConnection.Call.BadVersion":
						//Packet encoded in an unidentified format.
						break;
					case "NetConnection.Call.Prohibited":
						//An Action Message Format (AMF) operation is prevented for security reasons. Either the AMF URL is not in the same domain as the SWF file, or the AMF server does not have a policy file that trusts the domain of the SWF file. 
						break;
					case "NetConnection.Call.Failed":
						//The connection attempt failed.
						break;
					case "NetConnection.Connect.AppShutdown":
						//The specified application is shutting down.
						break;
					case "NetConnection.Connect.InvalidApp":
						//The application name specified during connect is invalid.
						break;
					case "SharedObject.Flush.Failed":
						//The "pending" status is resolved, but the SharedObject.flush() failed.
						break;
					case "SharedObject.BadPersistence":
						//A request was made for a shared object with persistence flags, but the request cannot be granted because the object has already been created with different flags.
						break;
					case "SharedObject.UriMismatch":
						//An attempt was made to connect to a NetConnection object that has a different URI (URL) than the shared object.
						break;*/
					case "NetStream.FileStructureInvalid":
						trace2("NetStreamPlayer::netStatusHandler - Error : The MP4's file structure is invalid. (" + e.info.code + ")");
						stop();
						break;
					case "NetStream.NoSupportedTrackFound":
						trace2("NetStreamPlayer::netStatusHandler - Error : The MP4 doesn't contain any supported tracks. (" + e.info.code + ")");
						stop();
						break;
						
					/* Warnings */
					/*case "NetStream.Play.InsufficientBW":
						//Flash Media Server only. The client does not have sufficient bandwidth to play the data at normal speed. 
						break;*/
					
					/* Status */
					/*case "NetStream.Buffer.Empty":
						//pause(true);
						break;
					case "NetStream.Buffer.Full":
						//pause(false);
						break;
					case "NetStream.Buffer.Flush":
						// Data has finished streaming, and the remaining buffer will be emptied.
						break;
					case "NetStream.Publish.Start":
						//Publish was successful.
						break;
					case "NetStream.Publish.Idle":
						//The publisher of the stream is idle and not transmitting data.
						break;
					case "NetStream.Unpublish.Success":
						//The unpublish operation was successful.
						break;*/
					case "NetStream.Play.Start":
						// Video started
						if (!_autoStart) {
							pause(true);
							_autoStart = true;
						}
						break;
					case "NetStream.Play.Stop":
						stop();
						dispatchEvent(new Event(PlayProgressEvent.PLAY_COMPLETE));
						break;
					/*case "NetStream.Play.Reset":
						//Caused by a play list reset.
						break;
					case "NetStream.Play.PublishNotify":
						//The initial publish to a stream is sent to all subscribers.
						break;
					case "NetStream.Play.UnpublishNotify":
						//An unpublish from a stream is sent to all subscribers.
						break;
					case "NetStream.Pause.Notify":
						// Paused
						break;
					case "NetStream.Unpause.Notify":
						// Resumed
						break;
					case "NetStream.Record.Start":
						// Recording has started.
						break;
					case "NetStream.Record.Stop":
						// Recording stopped.
						break;*/
					case "NetStream.Seek.Notify":
						// Seek was successful, delay it a bit so it's called after this event has completed becuase the actual
						// progress information hasnt updated yet.
						setTimeout(updateProgress, 50);
						break;
					/*case "NetConnection.Connect.Closed":
						//The connection was closed successfully.*/
					case "NetConnection.Connect.Success":
						//The connection attempt succeeded.
						createStream();
						break;
					/*case "SharedObject.Flush.Success":
						//The "pending" status is resolved and the SharedObject.flush() call succeeded.
						break;*/
				}
			} catch (error:Error) {
				// Ignore this error
				trace2("NetStreamPlayer::netStatusHandler - Error : " + error.message);
			}
		}
		
		private function onPlayTimer(event:TimerEvent):void {
			if (!sendOnce && vid) {
				if (vid.videoHeight != 0 && vid.videoWidth != 0) {
					dispatchEvent(new Event(PlayProgressEvent.PLAY_START));
					sendOnce = true;
				}
			}
			
			updateProgress();
		}
		
		private function updateSoundTransform():void {
			if (ns) {
				var transform:SoundTransform = ns.soundTransform;
				transform.volume = _mute ? 0 : _volume;
				transform.leftToLeft = _leftToLeft;
				transform.leftToRight = _leftToRight;
				transform.rightToLeft = _rightToLeft;
				transform.rightToRight = _rightToRight;
				ns.soundTransform = transform;
				
				_pan = ns.soundTransform.pan;
			}
		}
		
		private function trace2(...arguements):void {
			if (debug) trace(arguements);
		}
		
		private function updateProgress():void {
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
	}
}