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
/*
	-MetaData
	** Flash Player 9 and later supports ID3 2.0 tags, specifically 2.3 and 2.4
	-IDE 2.0 tag
	COMM Sound.id3.comment
	TABL Sound.id3.album
	TCON Sound.id3.genre
	TIT2 Sound.id3.songName
	TPE1 Sound.id3.artist
	TRCK Sound.id3.track
	TYER Sound.id3.year

	-ID3 Earlier
	TFLT File type
	TIME Time
	TIT1 Content group description
	TIT2 Title/song name/content description
	TIT3 Subtitle/description refinement
	TKEY Initial key
	TLAN Languages
	TLEN Length
	TMED Media type
	TOAL Original album/movie/show title
	TOFN Original filename
	TOLY Original lyricists/text writers
	TOPE Original artists/performers
	TORY Original release year
	TOWN File owner/licensee
	TPE1 Lead performers/soloists
	TPE2 Band/orchestra/accompaniment
	TPE3 Conductor/performer refinement
	TPE4 Interpreted, remixed, or otherwise modified by
	TPOS Part of a set
	TPUB Publisher
	TRCK Track number/position in set
	TRDA Recording dates
	TRSN Internet radio station name
	TRSO Internet radio station owner
	TSIZ Size
	TSRC ISRC (international standard recording code)
	TSSE Software/hardware and settings used for encoding
	TYER Year
	WXXX URL Link frame

	-Events
	complete
	id3
	ioError
	open
	progress
	
	TODO: Fade in/out when seeking
*/

package cv.media {
	
	import cv.events.LoadEvent;
	import cv.events.MetaDataEvent;
	import cv.events.PlayProgressEvent;
	import cv.interfaces.IMediaPlayer;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.media.Video;
	
	//--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched as ID3 metadata is receieved from an MP3
	 *
	 * @eventType cv.events.MetaDataEvent.AUDIO_METADATA
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "audioMetadata", type = "cv.events.MetaDataEvent")]
	
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
	 * @eventType cv.event.LoadEvent.LOAD_START
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

	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * <h3>Version:</h3> 2.1.1<br>
	 * <h3>Date:</h3> 3/06/2009<br>
	 * <h3>Updates At:</h3> http://blog.coursevector.com/tempolite<br>
	 * <br>
	 * The SoundPlayer class is a facade for controlling loading, and playing
	 * of MP3 files within Flash. It intelligently handles pausing, mute and
	 * loading.
	 * 
	 * @see cv.interfaces.IMediaPlayer
     */
    public class SoundPlayer extends EventDispatcher implements IMediaPlayer {
		
		/**
         * The current version
		 */
		public static const VERSION:String = "2.1.1";
		
		public static const SOUND:String = "sound";
		public var debug:Boolean = false;
		
		private var _buffer:int = 1;
		private var _loadCurrent:Number;
		private var _loadTotal:Number;
		private var _metaData:Object;
		private var _mute:Boolean = false;
		private var _isPause:Boolean = false;
		private var _volume:Number = 1;
		private var _leftToLeft:Number = 1;
		private var _leftToRight:Number = 0;
		private var _rightToLeft:Number = 0;
		private var _rightToRight:Number = 1;
		private var _pan:Number = 0;
		private var _isPlaying:Boolean = false;
		private var _isReadyToPlay:Boolean = false;
		private var pausePosition:int = 0;
		private var playTimer:Timer = new Timer(10);
		private var sc:SoundChannel;
		private var snd:Sound = new Sound();
		private var sendOnce:Boolean = false;
		private var _autoStart:Boolean;
		
		public function SoundPlayer() {
			playTimer.addEventListener(TimerEvent.TIMER, soundHandler);
        }
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
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
		 * Gets or sets how long SoundPlayer should buffer the audio before playing, in seconds.
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
			if(n < 0) n = 0;
			_buffer = n;
		}
		
		/** 
		 * Gets the current play progress in terms of percent
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get currentPercent():uint { return sc ? uint(100 * (sc.position / timeTotal)) : 0 }
		
		/** 
		 * If SoundPlayer is currently paused.
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
		 * If SoundPlayer is currently playing.
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
		 * If SoundPlayer is ready to play.
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
			if (sc) {
				var transform:SoundTransform = sc.soundTransform;
				transform.pan = _pan;
				sc.soundTransform = transform;
				
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
		 * Gets the elapsed play time in milliseconds
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get timeCurrent():Number { return sc ? sc.position : 0 }
		
		/** 
		 * Gets the remaining play time in milliseconds
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get timeLeft():Number { return sc ? timeTotal - sc.position : 0 }
		
		/** 
		 * Gets the total play time in milliseconds
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get timeTotal():Number { return getEstimatedLength() }
		
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
		 * Validates if the given filetype is compatible to be played with SoundPlayer. The only acceptable type is 'mp3'.
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
			return ("mp3" == str);
		}
		
		/**
		 * Loads a new file to be played.
		 * 
		 * @param s	The url of the file to be loaded
		 * @param autoStart Whether the file auto plays once loading is done
		 * 
		 * @see cv.events.LoadEvent.LOAD_START
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function load(s:String, autoStart:Boolean):void {
			if (s == "" || s == null) {
				trace2("SoundPlayer::load - Error : Must enter a url to load a file");
				return;
			}
			
			unload();
			
			var strURL:String = unescape(s);
			_autoStart = autoStart;
			
			snd = new Sound();
			snd.addEventListener(Event.COMPLETE, soundHandler, false, 0, true);
			snd.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
			snd.addEventListener(Event.ID3, soundHandler, false, 0, true);
			snd.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			snd.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
			snd.load(new URLRequest(strURL), new SoundLoaderContext(_buffer * 1000, true));
			
			isReadyToPlay = true;
			sendOnce = false;
			play();
			
			dispatchEvent(new LoadEvent(LoadEvent.LOAD_START, false, false, strURL, SOUND, timeTotal));
		}
		
		/**
		 * Loads a new file to be played.
		 * 
		 * @param	sound	The sound object from the library
		 * @param autoStart Whether the file auto plays once loading is done
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		/**
		 * 
		 * @param	sound
		 * @param	autoStart
		 */
		public function loadAsset(sound:Sound, autoStart:Boolean):void {
			if (sound == null) {
				trace2("SoundPlayer::loadAsset - Error : Must enter a sound to load");
				return;
			}
			
			unload();
			_autoStart = autoStart;
			
			snd = sound;
			snd.addEventListener(Event.ID3, soundHandler, false, 0, true);
			
			isReadyToPlay = true;
			sendOnce = false;
			play();
		}
		
		/**
		 * Controls the mute of the audio
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
		 * Controls the pause of the audio
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
			
			if(b) {
				stop(sc.position);
			} else {
				play(pausePosition);
			}
			
			dispatchEvent(new Event(Event.CHANGE));
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		/**
		 * Plays the audio, starting at the given position.
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
					if (pos == 0 && pausePosition != 0) pos = pausePosition;
					if (sc) sc.removeEventListener(Event.SOUND_COMPLETE, soundHandler);
					sc = snd.play(pos);
					updateSoundTransform();
					sc.addEventListener(Event.SOUND_COMPLETE, soundHandler, false, 0, true);
					isPlaying = true;
					pausePosition = 0;
					
					playTimer.start();
				}
			}
		}
		
		/**
		 * Seeks to time given in the audio.
		 * 
		 * @param n	Seconds into the audio to seek to
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seek(n:Number):void {
			n = Math.max(0, Math.min(snd.length, n * 1000));
			if(!isPause) {
				stop();
				play(n);
			} else {
				pausePosition = n;
			}
			dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
		}
		
		/**
		 * Seeks to the given percent in the audio
		 * 
		 * @param n	Percent to seek to
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seekPercent(n:Number):void {
			seek(((n * getEstimatedLength()) / 100) / 1000);
		}
		
		/**
		 * Stops the audio at the specified position. Sets the position given as the pause position.
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
			if (isPlaying || isPause) {
				pausePosition = pos;
				if(sc) sc.stop();
				playTimer.stop();
				isPlaying = false;
			}
		}
		
		/**
		 * Stops the audio, closes the sound class, and resets the metadata.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function unload():void {
			stop();
			try {
				snd.close();
			} catch (error:IOError) {
				// Isn't streaming/loading any longer
				//trace2("SoundPlayer::unload - Error: " + error.message);
			}
			_isPause = false;
			_isPlaying = false;
			isReadyToPlay = false;
			_metaData = null;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function errorHandler(e:ErrorEvent):void {
			trace2("SoundPlayer::load - Error: " + e.text);
		}
		
		private function getEstimatedLength():int {
			// If the metadata length is available, use that instead
			var n:int = Math.ceil(snd.length / (snd.bytesLoaded / snd.bytesTotal));
			return (_metaData) ? (_metaData.TLEN) ? _metaData.TLEN : n : n;
		}
		
		private function progressHandler(e:ProgressEvent):void {
			_loadCurrent = e.bytesLoaded;
			_loadTotal = e.bytesTotal;
			dispatchEvent(new ProgressEvent(LoadEvent.LOAD_PROGRESS, false, false, e.bytesLoaded, e.bytesTotal));
		}
		
		private function soundHandler(e:Event):void {
			switch (e.type) {
				case Event.COMPLETE :
					dispatchEvent(new Event(LoadEvent.LOAD_COMPLETE));
					break;
				case Event.ID3 :
					_metaData = e.target.id3;
					dispatchEvent(new MetaDataEvent(MetaDataEvent.AUDIO_METADATA, false, false, _metaData));
					break;
				case Event.SOUND_COMPLETE :
					dispatchEvent(new Event(PlayProgressEvent.PLAY_COMPLETE));
					break;
				case TimerEvent.TIMER :
					if (!sendOnce) {
						dispatchEvent(new Event(PlayProgressEvent.PLAY_START));
						
						sendOnce = true;
						if (_autoStart == false) {
							pause(true);
							_autoStart = true;
						}
					}
					
					dispatchEvent(new PlayProgressEvent(PlayProgressEvent.PLAY_PROGRESS, false, false, currentPercent, timeCurrent, timeLeft, timeTotal));
					break;
			}
		}
		
		private function updateSoundTransform():void {
			if (sc) {
				var transform:SoundTransform = sc.soundTransform;
				transform.volume = _mute ? 0 : _volume;
				transform.leftToLeft = _leftToLeft;
				transform.leftToRight = _leftToRight;
				transform.rightToLeft = _rightToLeft;
				transform.rightToRight = _rightToRight;
				sc.soundTransform = transform;
				
				_pan = sc.soundTransform.pan;
			}
		}
		
		private function trace2(...arguements):void {
			if (debug) trace(arguements);
		}
	}
}