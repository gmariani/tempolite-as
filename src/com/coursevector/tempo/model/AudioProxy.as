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
 * A single class to control both the Video and Audio proxy
 * 
 * TODO: Fade in/out when seeking
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

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
*/

package com.coursevector.tempo.model {
	
    import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.interfaces.IMediaProxy;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.TimerEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.utils.Timer;

    public class AudioProxy extends Proxy implements IProxy, IMediaProxy {
        public static const NAME:String = 'AudioProxy';
		
		private var _buffer:int = 1;
		private var _loadCurrent:Number;
		private var _loadTotal:Number;
		private var _metaData:Object;
		private var _mute:Boolean = false;
		private var _pause:Boolean = false;
		private var _volume:Number = 1;
		private var fileTypes:Array = ["mp3"];
		private var isPlaying:Boolean = false;
		private var isReadyToPlay:Boolean = false;
		private var pausePosition:int = 0;
		private var playTimer:Timer = new Timer(10);
		private var sc:SoundChannel;
		private var snd:Sound = new Sound();
		private var strExt:String;
		private var sendOnce:Boolean = false;
		
		public function AudioProxy() {
            super(NAME);
			
			playTimer.addEventListener(TimerEvent.TIMER, soundHandler);
        }
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		// In seconds
		public function get buffer():int { return _buffer }
		public function set buffer(n:int):void {
			if(n < 0) n = 0;
			_buffer = n;
		}
		
		public function get isPause():Boolean { return _pause }
		
		public function get currentPercent():uint { return sc ? uint(100 * (sc.position / timeTotal)) : 0 }
		
		public function get loadCurrent():Number { return _loadCurrent ? _loadCurrent : 0 }
		
		public function get loadTotal():Number { return _loadTotal ? _loadTotal : 0 }
		
		public function get metaData():Object { return _metaData }
		
		public function get timeCurrent():Number { return sc ? sc.position : 0 }
		
		public function get timeLeft():Number { return sc ? timeTotal - sc.position : 0 }
		
		public function get timeTotal():Number { return getEstimatedLength() }
		
		public function get volume():Number { return _volume }
		public function set volume(n:Number):void {
			_volume = Math.max(0, Math.min(1, n));
			updateVolume();
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function isValid(str:String):Boolean {
			strExt = str;
			return !(fileTypes.every(checkFileType));
		}
		
		public function load(s:String):void {
			if (s == "" || s == null) {
				trace("AudioProxy::load - Error : Must enter a url to load a file");
				return;
			}
			
			unLoad();
			
			var strURL:String = unescape(s);
			
			snd = new Sound();
			snd.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			snd.addEventListener(Event.ID3, soundHandler);
			snd.addEventListener("ioError", errorHandler);
			snd.addEventListener("securityError", errorHandler);
			snd.load(new URLRequest(strURL), new SoundLoaderContext(_buffer * 1000, true));
			
			isReadyToPlay = true;
			sendOnce = false;
			play();
			sendNotification(ApplicationFacade.LOAD_START, {url:strURL, type:"audio", time:timeTotal});
		}
		
		public function mute(b:Boolean = true):void {
			_mute = b;
			updateVolume();
		}
		
		public function pause(b:Boolean = true):void {
			_pause = b;
			if(b) {
				stop(sc.position);
			} else {
				play(pausePosition);
			}
		}
		
		public function play(pos:int = 0):void {
			if (!isPlaying) {
				if (isReadyToPlay) {
					if (pos == 0 && pausePosition != 0) pos = pausePosition;
					sc = snd.play(pos);
					updateVolume();
					sc.addEventListener(Event.SOUND_COMPLETE, soundHandler);
					_pause = false;
					isPlaying = true;
					pausePosition = 0;
					
					playTimer.start();
				}
			}
		}
		
		public function seekPercent(n:Number):void {
			seek(((n * getEstimatedLength()) / 100) / 1000);
		}
		
		public function seek(n:Number):void {
			n = Math.max(0, Math.min(snd.length, n * 1000));
			if(!_pause) {
				stop();
				play(n);
			} else {
				pausePosition = n;
			}
		}
		
		public function stop(pos:int = 0):void {
			if (isPlaying || _pause) {
				pausePosition = pos;
				sc.stop();
				playTimer.stop();
				isPlaying = false;
			}
		}
		
		public function unLoad():void {
			stop();
			try {
				if(snd) snd.close();
			} catch (error:IOError) {
				// Isn't streaming/loading any longer
				//trace(error.message);
			}
			_pause = false;
			isReadyToPlay = false;
			_metaData = null;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function checkFileType(item:String, idx:int, arr:Array):Boolean {
			return (item != strExt);
		}
		
		private function errorHandler(e:ErrorEvent):void {
			trace("AudioProxy::load - Error: " + e.text);
		}
		
		private function getEstimatedLength():int {
			// If the metadata length is available, use that instead
			var estLen:int = Math.ceil(snd.length / (snd.bytesLoaded / snd.bytesTotal));
			return (_metaData) ? (_metaData.TLEN) ? _metaData.TLEN : estLen : estLen;
		}
		
		private function progressHandler(e:ProgressEvent):void {
			_loadCurrent = e.bytesLoaded;
			_loadTotal = e.bytesTotal;
			sendNotification(ApplicationFacade.LOAD_PROGRESS, {loaded:e.bytesLoaded, total:e.bytesTotal});
		}
		
		private function soundHandler(e:Event):void {
			switch (e.type) {
				case Event.ID3 :
					_metaData = e.target.id3;
					sendNotification(ApplicationFacade.AUDIO_METADATA, _metaData);
					break;
				case Event.SOUND_COMPLETE :
					sendNotification(ApplicationFacade.PLAY_COMPLETE);
					sendNotification(ApplicationFacade.NEXT);
					break;
				case TimerEvent.TIMER :
					if (!sendOnce) {
						sendNotification(ApplicationFacade.PLAY_START, { type:"audio", time:timeTotal } );
						sendOnce = true;
					}
					sendNotification(ApplicationFacade.PLAY_PROGRESS, {percent:currentPercent, elapsed:timeCurrent, remain:timeLeft, total:timeTotal});
					break;
			}
		}
		
		private function updateVolume():void {
			if(sc) sc.soundTransform = new SoundTransform(_mute ? 0 : _volume);
		}
	}
}