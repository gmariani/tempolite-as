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
 * TODO: Add SMIL Support
 * TODO: Add iTunes RSS
 * TODO: Add Media RSS
 */

package cv {

	import cv.data.PlayList;
	import cv.events.CuePointEvent;
	import cv.events.LoadEvent;
	import cv.events.MetaDataEvent;
	import cv.events.PlayProgressEvent;
	import cv.interfaces.IMediaPlayer;
	import cv.managers.PlayListManager;
	import cv.media.SoundPlayer;
	import cv.media.NetStreamPlayer;
	
	import flash.display.Sprite;
	import flash.events.Event;
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
	 * Dispatched from the PlayList when a change has occured
	 *
	 * @eventType cv.TempoLite.CHANGE
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "change", type = "flash.events.Event")]
	
	/**
	 * Dispatched everytime a cue point is encountered
	 *
	 * @eventType cv.events.CuePointEvent.CUE_POINT
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name="cuePoint", type="cv.events.CuePointEvent")]
	
	/**
	 * Dispatched as a media file is loaded
	 *
	 * @eventType cv.TempoLite.LOAD_PROGRESS
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "loadProgress", type = "flash.events.ProgressEvent")]
	
	/**
	 * Dispatched as a media file begins loading
	 *
	 * @eventType cv.TempoLite.LOAD_START
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "loadStart", type = "cv.LoadEvent")]
	
	/**
	 * Dispatched after Tempo has begun loading the next item, also at the end of an item playing
	 *
	 * @eventType cv.TempoLite.NEXT
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "next", type = "flash.events.Event")]
	
	/**
	 * Dispatched as a media file finishes playing
	 *
	 * @eventType cv.TempoLite.PLAY_COMPLETE
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
	 * @eventType cv.TempoLite.PLAY_START
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "playStart", type = "flash.events.Event")]
	
	/**
	 * Dispatched after Tempo has begun loading the previous item
	 *
	 * @eventType cv.TempoLite.PREVIOUS
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "previous", type = "flash.events.Event")]
	
	/**
	 * Dispatched from the PlayListManager when ever an item is removed, or updated, or the entire list is updated
	 *
	 * @eventType cv.TempoLite.REFRESH_PLAYLIST
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "refreshPlaylist", type = "flash.events.Event")]
	
	/**
	 * Dispatched whenever the isPlaying, isReadyToPlay or isPause properties have changed.
	 *
	 * @eventType cv.TempoLite.STATUS
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "status", type = "flash.events.Event")]
	
	/**
	 * Dispatched as metadata is receieved from an video stream of M4A file
	 *
	 * @eventType cv.events.MetaDataEvent.VIDEO_METADATA
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name="videoMetadata", type="cv.events.MetaDataEvent")]
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * <h3>Version:</h3> 2.1.1<br>
	 * <h3>Date:</h3> 3/06/2009<br>
	 * <h3>Updates At:</h3> http://blog.coursevector.com/tempolite<br>
	 * <br>
	 * TempoLite is based off of its sister project Tempo this is a parsed down version that 
	 * does not handle a UI. TempoLite is best compared with players like video.Maru, in 
	 * the sense that it’s just a component that is dragged on stage and handles all of 
	 * the media playback. This allows for a UI as complicated as you want to make it while 
	 * the actually playback is handled by TempoLite.
	 * <br>
	 * <br>
	 * <h3>Coded By:</h3> Gabriel Mariani, gabriel[at]coursevector.com<br>
	 * Copyright 2009, Course Vector (This work is subject to the terms in http://blog.coursevector.com/terms.)<br>
	 * <br>
	 * <h3>Notes:</h3>
	 * <ul>
	 * 		<li>This class will add about 15kb to your Flash file.</li>
	 * </ul>
	 * <hr>
	 * <ul>
	 * <li>2.1.1
	 * <ul>
	 * 		<li>Changed unloadMedia() to just unload()</li>
	 * 		<li>Changed bufferTime to just buffer</li>
	 * </ul>
	 * </li>
	 * <li>2.1.0
	 * <ul>
	 * 		<li>Re-organized class structure. AudioManager and VideoManager are now SoundPlayer and NetStreamPlayer</li>
	 * 		<li>Re-organized class structure. IMediaManager is now IMediaPlayer</li>
	 * 		<li>Re-organized class structure. PlayListManager is now under the managers package</li>
	 * 		<li>Fixed autoStart, items would load paused but think they were playing. This time with the SoundPlayer</li>
	 * </ul>
	 * </li>
	 * <li>2.0.7
	 * <ul>
	 * 		<li>Added PLAY_PROGRESS event dispatch after seek</li>
	 * 		<li>Removed traces</li>
	 * 		<li>Added STATUS event, dispatched whenever the isPause, isPlaying, isReadyToPlay properties change.</li>
	 * 		<li>Fixed autoStart, items would load paused but think they were playing.</li>
	 * </ul>
	 * </li>
	 * <li>2.0.6
	 * <ul>
	 * 		<li>Added leftToLeft property</li>
	 * 		<li>Added leftToRight property</li>
	 * 		<li>Added rightToLeft property</li>
	 * 		<li>Added rightToRight property</li>
	 * 		<li>Added pan property</li>
	 * 		<li>Changed stringToTime and timeToString into static methods</li>
	 * </ul>
	 * </li>
	 * <li>2.0.5
	 * <ul>
	 * 		<li>Fixed autoStart, pause now dispatches a Progress and Change event</li>
	 * </ul>
	 * </li>
	 * <li>2.0.4
	 * <ul>
	 * 		<li>Added CUE_POINT contstant</li>
	 * </ul>
	 * </li>
	 * <li>2.0.3
	 * <ul>
	 * 		<li>Fixed getTimeCurrent, getTimeTotal, getTimeLeft to return time as milliseconds and not a decimal number.</li>
	 * </ul>
	 * </li>
	 * <li>2.0.2
	 * <ul>
	 * 		<li>Changed how time is retrieved. Time is returned in milliseconds, must use conversion functions to get strings.</li>
	 * 		<li>Added stringToTime()</li>
	 * 		<li>Updated timeToString()</li>
	 * </ul>
	 * </li>
	 * <li>2.0.1
	 * <ul>
	 * 		<li>Fixed Video MetaData handler</li>
	 * 		<li>Fixed video scaling issue on initial play</li>
	 * 		<li>Fix playlist file type handling</li>
	 * 		<li>Fixed null playlist handling</li>
	 * </ul>
	 * </li>
	 * <li>2.0.0
	 * <ul>
	 * 		<li>Removed PureMVC framework</li>
	 * 		<li>Dropped compiled size by almost 10Kb</li>
	 * 		<li>Updated XSPF parser</li>
	 * 		<li>Updated ASX parser</li>
	 * 		<li>Added ATOM as a playlist type</li>
	 * 		<li>Removed B4S as a playlist type</li>
	 * 		<li>Removed PLS as a playlist type</li>
	 * 		<li>Added streaming video capability</li>
	 * </ul>
	 * </li>
	 * <li>1.1.0
	 * <ul>
	 * 		<li>Added file extension override</li>
	 * 		<li>Fixed pause bug</li>
	 * 		<li>Updated to PureMVC AS3 Multicore 1.0.5</li>
	 * </ul>
	 * </li>
	 * <li>1.0.3
	 * <ul>
	 * 		<li>Updated to Tempo 1.0.3</li>
	 * </ul>
	 * </li>
	 * <li>1.0.2
	 * <ul>
	 *		 <li>Fixed int comparison bug in removeItem, addItem, and play. Introduced in 1.0.1</li>
	 * </ul>
	 * </li>
	 * <li>1.0.1
	 * <ul>
	 * 		<li>Fixed issue of adding/removing item from playlist at index '0'</li>
	 * 		<li>Added events TempoLite.NEXT and TempoLite.PREVIOUS</li>
	 * 		<li>Playlist will automatically update with metadata as it's received</li>
	 * 		<li><code>loadMedia()</code> method allows for autoStart to be set</li>
	 * </ul>
	 * </li>
	 * <li>1.0.0
	 * <ul>
	 * 		<li>Changed how the repeat property is handled. Instead of a boolean, it now passes a string. Accepted values are TempoLite.REPEAT_TRACK, TempoLite.REPEAT_ALL, and TempoLite.REPEAT_NONE</li>
	 * </ul>
	 * </li>
	 * <li>0.9.5
	 * <ul>
	 * 		<li>Added TempoLite.PLAY_START event</li>
	 * 		<li>Added <code>version</code> property</li>
	 * </ul>
	 * </li>
	 * <li>0.9.4
	 * <ul>
	 * 		<li>Added isPause property</li>
	 * 		<li>Added boolean as a possible arguement for <code>pause()</code></li>
	 * </ul>
	 * </li>
	 * <li>0.9.3
	 * <ul>
	 *		 <li>New api added</li>
	 * </ul>
	 * </li>
	 * <li>0.9.1
	 * <ul>
	 * 		<li>Upgraded to PureMVC AS3 MultiCore Beta 1.0.1</li>
	 * 		<li>Tighter integration with Tempo</li>
	 * 		<li>Can run concurrently with Tempo without breaking</li>
	 * 		<li>Standardized API</li>
	 * 		<li>Cleaned up source code</li>
	 * </ul>
	 * </li>
	 * <li>0.9.0
	 * <ul>
	 * 		<li>Initial port of Tempo</li>
	 * </ul>
	 * </li>
	 * </ul>
	 * 
	 * @example Show example here
	 * 
     * @langversion 3.0
     * @playerversion Flash 9.0.115.0
     */
	
    public class TempoLite extends Sprite {
		
		/**
         * The current version of TempoLite in use.
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
		 */
		public static const VERSION:String = "2.1.1";
		
        // Notification name constants
        public static const CHANGE:String = "change";
		public static var debug:Boolean = false;
		
		// Audio/Video Proxy
		public static const PLAY_START:String = PlayProgressEvent.PLAY_START;
		public static const PLAY_PROGRESS:String = PlayProgressEvent.PLAY_PROGRESS;
		public static const PLAY_COMPLETE:String = PlayProgressEvent.PLAY_COMPLETE;
		public static const LOAD_START:String = LoadEvent.LOAD_START;
		public static const LOAD_PROGRESS:String = LoadEvent.LOAD_PROGRESS;
		public static const LOAD_COMPLETE:String = LoadEvent.LOAD_COMPLETE;
		public static const AUDIO_METADATA:String = MetaDataEvent.AUDIO_METADATA;
		public static const VIDEO_METADATA:String = MetaDataEvent.VIDEO_METADATA;
		public static const CUE_POINT:String = CuePointEvent.CUE_POINT;
		public static const STATUS:String = PlayProgressEvent.STATUS;
		
		// Playlist Proxy
		public static const NEXT:String = "next";
		public static const PREVIOUS:String = "prev";
		public static const REFRESH_PLAYLIST:String = "refreshPlaylist";
		public static const NEW_PLAYLIST:String = "newPlaylist";
		
		// PlayerEvent
		public static const REPEAT_TRACK:String = "track";
		public static const REPEAT_ALL:String = "all";
		public static const REPEAT_NONE:String = "none";
		public static const MAINTAIN_ASPECT_RATIO:String = "ratio";
		public static const NO_SCALE:String = "scale";
		public static const EXACT_FIT:String = "fit";
		
		// Settings
		protected var aM:IMediaPlayer;
		protected var cM:IMediaPlayer;
		protected var plM:PlayListManager;
		protected var screenHeight:Number;
		protected var screenWidth:Number;
		protected var screenX:Number;
		protected var screenY:Number;
		protected var vidScreen:Video;
		protected var vM:IMediaPlayer;
		
		/**
		 * Constructor. 
		 * 
		 * <P>
		 * This creates a new TempoLite instance.
		 * 
		 */
		public function TempoLite() {
			trace("Course Vector TempoLite: v" + VERSION);
			
			aM = new SoundPlayer();
			initMedia(aM);
			aM.addEventListener(MetaDataEvent.AUDIO_METADATA, metaDataHandler); //MetaDataEvent
			
			vM = new NetStreamPlayer();
			initMedia(vM);
			vM.addEventListener(MetaDataEvent.VIDEO_METADATA, metaDataHandler); //MetaDataEvent
			vM.addEventListener(CuePointEvent.CUE_POINT, eventHandler);
			
			// Set current media manager
			cM = vM;
			
			plM = new PlayListManager();
			plM.addEventListener(TempoLite.NEW_PLAYLIST, playlistHandler);
			plM.addEventListener(TempoLite.REFRESH_PLAYLIST, eventHandler);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/** 
		 * Whether a video will play immediately when a playlist is loaded.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get autoStart():Boolean { return plM.autoStart; }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set autoStart(b:Boolean):void {
			plM.autoStart = b;
			if(aM) aM.autoStart = b;
			if(vM) vM.autoStart = b;
		}
		
		/** 
		 * If autoStart is true, the index of the item in the playlist to play first.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get autoStartIndex():int { return plM.autoStartIndex }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set autoStartIndex(n:int):void {
			plM.autoStartIndex = n;
		}
		
		/** 
		 * The time in seconds to buffer a file before playing.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get buffer():int { return cM.buffer }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set buffer(n:int):void {
			if(aM) aM.buffer = n;
			if(vM) vM.buffer = n;
		}
		
		/** 
		 * If TempoLite is currently paused.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get isPause():Boolean { return cM.isPause }
		
		public function get isPlaying():Boolean { return cM.isPlaying }
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left input is played in the left speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get leftToLeft():Number { return cM.leftToLeft }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set leftToLeft(n:Number):void {
			if(aM) aM.leftToLeft = n;
			if(vM) vM.leftToLeft = n;
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left input is played in the right speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get leftToRight():Number { return cM.leftToRight }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set leftToRight(n:Number):void {
			if(aM) aM.leftToRight = n;
			if(vM) vM.leftToRight = n;
		}
		
		/** 
		 * Retrieves the number of items in the playlist.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get length():uint { return plM.list.length }
		
		/** 
		 * The left-to-right panning of the sound, ranging from -1 (full pan left) to 1 (full pan right). 
		 * A value of 0 represents no panning (balanced center between right and left). 
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get pan():Number { return cM.pan }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set pan(n:Number):void {
			if(aM) aM.pan = n;
			if(vM) vM.pan = n;
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right input is played in the left speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get rightToLeft():Number { return cM.rightToLeft }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set rightToLeft(n:Number):void {
			if(aM) aM.rightToLeft = n;
			if(vM) vM.rightToLeft = n;
		}
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right input is played in the right speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get rightToRight():Number { return cM.rightToRight }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		public function set rightToRight(n:Number):void {
			if(aM) aM.rightToRight = n;
			if(vM) vM.rightToRight = n;
		}
		
		/** 
		 * Sets whether repeat is enabled, or which type of repeat is enabled.
		 * Accepted values are:
		 * <li>TempoLite.REPEAT_ALL</li>
		 * <li>TempoLite.REPEAT_TRACK</li>
		 * <li>TempoLite.REPEAT_NONE</li>
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get repeat():String {
			if(plM) return plM.repeat;
			return TempoLite.REPEAT_NONE;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set repeat(str:String):void {
			switch(str) {
				case TempoLite.REPEAT_ALL:
				case TempoLite.REPEAT_NONE:
				case TempoLite.REPEAT_TRACK:
					break;
				default:
					return;
			}
			
			plM.repeat = str;
		}
		
		/** 
		 * Whether to shuffle the playlist or not.
		 *
		 * @default false
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get shuffle():Boolean { return plM.shuffle }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set shuffle(b:Boolean):void { plM.shuffle = b; }
		
		/** 
		 * The version of TempoLite in use.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public static function get version():String { return VERSION }
		
		/** 
		 * A number from 0 to 1 determines volume.
		 *
		 * @default 0.5
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get volume():Number { return cM.volume }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set volume(n:Number):void {
			var v:Number = Math.max(0, Math.min(1, n));
			if(aM) aM.volume = v;
			if(vM) vM.volume = v;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Add an item to the playlist at the end, or at index specified.
		 * 
		 * @param item	item to be added.
		 * 
		 * @default -1
		 * @param index where the item should be added in the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function addItem(item:Object, index:int = -1):void { 
			plM.addItem(item, index);
		}
		
		/**
		 * Clears the current playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function clearItems():void {
			plM.clear();
		}
		
		/**
		 * Retrieve the current index in the playlist.
		 * 
		 * @return the index of the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getCurrentIndex():uint { return plM.list.index	}
		
		/**
		 * Retrieve the current item playing.
		 * 
		 * @return the current item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getCurrentItem():Object { return plM.list.getCurrent() }
		
		/**
		 * Retrieve the current play progress as a percent.
		 * 
		 * @return the play progress in terms of percent.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getCurrentPercent():uint { return cM.currentPercent }
		
		/**
		 * Retrieve the current playlist in <code>PlayList</code> format (enhanced array).
		 * 
		 * @return the playlist as a <code>PlayList</code> type.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getList():PlayList { return plM.list }
		
		/**
		 * Retrieve the current bytes loaded of the current item.
		 * 
		 * @return the current bytes loaded of the item.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getLoadCurrent():Number { return cM.loadCurrent }
		
		/**
		 * Retrieve the total bytes to load of the current item.
		 * 
		 * @return the total bytes to load of the item.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getLoadTotal():Number {	return cM.loadTotal }
		
		/**
		 * Retrieve the metadata from the current item playing if available.
		 * 
		 * @return the metadata associated with the item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getMetaData():Object { return cM.metaData }
		
		/**
		 * Retrieve the current play time of the current item playing.
		 * 
		 * @return the current play time of the item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getTimeCurrent():int {
			var n:Number = cM.timeCurrent != 0 ? cM.timeCurrent / 1000 : 0;
			return int(String(n.toFixed(3)).replace(".", ""));
		}
		
		/**
		 * Retrieve the play time remaining of the current item playing.
		 * 
		 * @return the play time remaining of the item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getTimeLeft():int {
			var n:Number = cM.timeLeft != 0 ? cM.timeLeft / 1000 : 0;
			return -1 * int(String(n.toFixed(3)).replace(".", ""));
		}
		
		/**
		 * Retrieve the total play time of the current item playing.
		 * 
		 * @return the total play time of the item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getTimeTotal():int {
			var n:Number = cM.timeTotal != 0 ? cM.timeTotal / 1000 : 0;
			return int(String(n.toFixed(3)).replace(".", ""));
		}
		
		/**
		 * Create a playlist of a single item and load the item.
		 * 
		 * @param item item to be played.
		 * 
		 * @default true
		 * @param autoStart Whether the file will start playing as soon as possible
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function loadMedia(item:Object, autoStart:Boolean = true):void {
			plM.autoStart = autoStart;
			plM.loadSingle(item);
		}
		
		/**
		 * Loads a new playlist and clears any previous playlsit.
		 * 
		 * @default "playlists/Tempo.m3u"
		 * 
		 * @param url the path to the playlist file.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function loadPlayList(url:String = "playlists/vip.xspf"):void {
			if (url == null) url = "playlists/vip.xspf";
			plM.load(url);
		}
		
		/**
		 * Plays the next item in the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function next():void { 
			var o:Object = plM.getNext();
			if (o) load(o);
		}
		
		/**
		 * Pauses the current playback.
		 * 
		 * @default true
		 * 
		 * @param b Value to set pause to
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function pause(b:Boolean = true):void {
			cM.pause(b);
		}
		
		/**
		 * Plays the current item in the playlist, or at the 
		 * specified index in the playlist.
		 * 
		 * @default -1
		 * 
		 * @param index The index of the item to be played
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function play(index:int = -1):void {
			if (index >= 0) {
				plM.list.index = index;
				load(plM.list.getCurrent());
			} else {
				if (cM.isPlaying || cM.isPause) {
					cM.play();
				} else if(!cM.isPlaying && !cM.isPause) {
					if(plM.list.getCurrent()) load(plM.list.getCurrent());
				}
			}
		}
		
		/**
		 * Plays the previous item in the playlist.
		 * 
		 * @see #event:previous
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function previous():void {
			var o:Object = plM.getPrevious();
			if (o) load(o);
			dispatchEvent(new Event(TempoLite.PREVIOUS));
		}
		
		/**
		 * Remove an item from the playlist from the end, or at index specified.
		 * 
		 * @default -1
		 * 
		 * @param index The index of the item to be removed
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function removeItem(index:int = -1):void {
			plM.removeItem(index);
		}
		
		/**
		 * Seek to a specific time (in seconds) in the current item playing.
		 * 
		 * @param time Specific time to seek to, in seconds
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seek(time:Number):void {
			cM.seek(time * 1000);
		}
		
		/**
		 * Seek to a specific percent (0 - 1) in the current item playing.
		 * 
		 * @param percent Percentage to seek to
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seekPercent(percent:Number):void {
			cM.seekPercent(percent * 100);
		}
		
		/**
		 * Seek by the amount (in seconds) specified relative to the current play time.
		 * 
		 * @param time Amount to seek relative to current play time in seconds.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seekRelative(time:Number):void {
			cM.seek(cM.timeCurrent + (time * 1000));
		}
		
		/**
		 * Toggles mute.
		 * 
		 * @param b Value to set mute to
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function setMute(b:Boolean):void {
			if(aM) aM.mute(b);
			if(vM) vM.mute(b);
		}
		
		/**
		 * Used to specify a hosting server when streaming video
		 * 
		 * @param value The host url
		 * 
		 * @example <code>
		 * import cv.TempoLite;<br>
		 * <br>
		 * var vidScreen:Video = new Video();<br>
		 * this.addChild(vidScreen);<br>
		 * <br>
		 * var tempo:TempoLite = new TempoLite();<br>
		 * tempo.setStreamHost("rtmp://cp11111.edgefcs.net/ondemand");<br>
		 * tempo.loadMedia({url:"11111/VideoName", extOverride:"flv"});<br>
		 * tempo.setVideoScreen(vidScreen);<br>
		 * </code>
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function setStreamHost(value:String):void {
			if(vM) NetStreamPlayer(vM).streamHost = value;
		}
		
		/**
		 * Determines how TempoLite will scale a video. The options are 
		 * 
		 * <ul>
		 * <li>TempoLite.MAINTAIN_ASPECT_RATIO</li>
		 * <li>TempoLite.EXACT_FIT</li>
		 * <li>TempoLite.NO_SCALE</li>
		 * </ul>
		 * 
		 * @see #MAINTAIN_ASPECT_RATIO
		 * @see #EXACT_FIT
		 * @see #NO_SCALE
		 * 
		 * @param scaleMode scale mode to use for video scaling.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function setVideoScale(scaleMode:String):void {
			var v:Video = vidScreen;
			if (v) {
				switch(scaleMode) {
					case TempoLite.MAINTAIN_ASPECT_RATIO :
					case TempoLite.EXACT_FIT :
					case TempoLite.NO_SCALE :
						break;
					default :
						return;
				}
				
				var vidW:int = v.videoWidth;
				var vidH:int = v.videoHeight;
				switch (scaleMode) {
					case TempoLite.NO_SCALE :
						v.width = vidW;
						v.height = vidH;
						v.x = screenX;
						v.y = screenY;
						break;
					case TempoLite.EXACT_FIT :
						v.width = screenWidth;
						v.height = screenHeight;
						v.x = screenX;
						v.y = screenY;
						break;
					case TempoLite.MAINTAIN_ASPECT_RATIO :
					default:
						var newWidth:Number = (vidW * screenHeight / vidH);
						var newHeight:Number = (vidH * screenWidth / vidW);
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
		
		/**
		 * Assigns a video screen for TempoLite to display videos with.
		 * 
		 * @param video video display object to be used as a screen.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function setVideoScreen(video:Video):void {
			vidScreen = video;
			screenWidth = vidScreen.width;
			screenHeight = vidScreen.height;
			screenX = vidScreen.x;
			screenY = vidScreen.y;
			
			if(vM) NetStreamPlayer(vM).video = vidScreen;
		}
		
		/**
		 * Stops the selected item in the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function stop():void { cM.stop() }
		
		/**
		 * Converts a time in 00:00:000 format and converts it back into a number.
		 * 
		 * @param	text The string to convert
		 * @return The converted number
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function stringToTime(text:String):int {
            var arr:Array = text.split(":");
            var time:Number = 0;
            if (arr.length > 1) {
				// Milliseconds
                time = Number(arr[arr.length--]);
				// Seconds
				time += Number(arr[arr.length - 2]) * 60;
                if (arr.length == 3) {
					// Minutes
                    time += Number(arr[arr.length - 3]) * 3600;
                }
            } else {
                time = Number(text);
            }
            return int(time);
		}
		
		/**
		 * Converts milliseconds to a 00:00:000 format.
		 * 
		 * @param	n Milliseconds to convert
		 * @return The converted string
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public static function timeToString(n:int):String {
			var ms:int = int(n % 1000);
			var s:int = n / 1000;
			var m:int = int(s / 60);
			s = int(s % 60);
			return zero(m) + ":" + zero(s) + ":" + zero(ms, true);
		}
		
		/**
		 * Unloads the current item playing. 
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function unload():void {
			if(aM) aM.unload();
			if(vM) vM.unload();
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		protected static function zero(n:int, isMS:Boolean = false):String {
			if(isMS) {
				if(n < 10) return "00" + n;
				if(n < 100) return "0" + n;
			}
			if (n < 10) return "0" + n;
			return "" + n;
		}
		
		protected function eventHandler(e:Event):void {
			dispatchEvent(e.clone());
		}
		
		protected function initMedia(m:IMediaPlayer):void {
			m.addEventListener(LoadEvent.LOAD_START, eventHandler); //LoadEvent
			m.addEventListener(TempoLite.LOAD_PROGRESS, eventHandler); //ProgressEvent
			m.addEventListener(TempoLite.PLAY_COMPLETE, playlistHandler);
			m.addEventListener(TempoLite.PLAY_START, eventHandler);
			m.addEventListener(TempoLite.CHANGE, eventHandler);
			m.addEventListener(TempoLite.STATUS, eventHandler);
			m.addEventListener(PlayProgressEvent.PLAY_PROGRESS, eventHandler); // PlayProgressEvent
		}
		
		protected function load(o:Object):void {
			var ext:String = o.extOverride || o.url.substr( -3).toLowerCase();
			if (aM) aM.unload();
			if (vM) vM.unload();
			
			if (aM && aM.isValid(ext)) {
				cM = aM;
				aM.load(o.url, plM.autoStart);
			} else if (vM.isValid(ext) && vM) {
				cM = vM;
				vM.load(o.url, plM.autoStart);
			}
		}
		
		protected function metaDataHandler(e:MetaDataEvent):void {
			switch(e.type) {
				case MetaDataEvent.AUDIO_METADATA :
					if (e.data.TLEN) plM.updateItemLength(plM.list.index, e.data.TLEN);
					break;
				case MetaDataEvent.VIDEO_METADATA :
					if (e.data.duration) plM.updateItemLength(plM.list.index, e.data.duration * 1000);
					break;
			}
			dispatchEvent(e.clone());
		}
		
		protected function playlistHandler(e:Event):void {
			switch(e.type) {
				case TempoLite.PLAY_COMPLETE :
					next();
					dispatchEvent(e.clone());
					dispatchEvent(new Event(TempoLite.NEXT));
					break;
				case TempoLite.NEW_PLAYLIST :
					var l:PlayList = plM.list;
					if (plM.autoStart) l.index = plM.autoStartIndex;
					if(l.getCurrent()) load(l.getCurrent());
					
					// Reset listeners
					plM.list.removeEventListener(TempoLite.CHANGE, eventHandler);
					plM.list.addEventListener(TempoLite.CHANGE, eventHandler);
					break;
			}
		}
    }
}