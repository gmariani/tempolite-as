////////////////////////////////////////////////////////////////////////////////
//
//  COURSE VECTOR
//  Copyright 2009 Course Vector
//  All Rights Reserved.
//
//  NOTICE: Course Vector permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package cv.interfaces {
	
	import flash.events.IEventDispatcher;
	import flash.media.Video;
	
	/**
	 *  Implement the IMediaPlayer interface to create a custom media manager. 
	 *  A media manager handles audio or video playback.
	 *
	 *  @see cv.media.AudioPlayer
	 *  @see cv.media.VideoPlayer
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public interface IMediaPlayer extends IEventDispatcher {
		
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
		function get autoStart():Boolean;
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		function set autoStart(b:Boolean):void;
		
		/**
		 * Gets or sets the buffer value of a media manager. This controls
		 * how long a file is buffered before it begins to play.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get buffer():int;
		
		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function set buffer(n:int):void;
		
		/**
		 * Gets the play progress percentage of the currently
		 * playing media file.
		 * 
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get currentPercent():uint;
		
		/**
		 *  Gets the pause status of the media manager.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get isPause():Boolean;
		
		/**
		 *  Gets the playing status of the media manager.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get isPlaying():Boolean;
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left input is played in the left speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		function get leftToLeft():Number;
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		function set leftToLeft(n:Number):void;
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the left input is played in the right speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		function get leftToRight():Number;
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		function set leftToRight(n:Number):void;
		
		/**
		 *  Gets the number of bytes currently loaded.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get loadCurrent():Number;
		
		/**
		 *  Gets the total number of bytes for a given file
		 * being loaded.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get loadTotal():Number;
		
		/** 
		 * The left-to-right panning of the sound, ranging from -1 (full pan left) to 1 (full pan right). 
		 * A value of 0 represents no panning (balanced center between right and left). 
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		function get pan():Number;
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		function set pan(n:Number):void;
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right input is played in the left speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		function get rightToLeft():Number;
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		function set rightToLeft(n:Number):void;
		
		/** 
		 * A value, from 0 (none) to 1 (all), specifying how much of the right input is played in the right speaker.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		function get rightToRight():Number;
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0
         */
		function set rightToRight(n:Number):void;
		
		/**
		 *  Gets or sets the volume of the media manager.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get volume():Number;
		
		/**
         *  @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function set volume(n:Number):void;
		
		/**
		 *  Gets the meta data object of the current file if available.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get metaData():Object;
		
		/**
		 *  Gets the elapsed play time of the current file.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get timeCurrent():Number;
		
		/**
		 *  Gets the remaining play time of the current file.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get timeLeft():Number;
		
		/**
		 *  Gets the total play time of the current file.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function get timeTotal():Number;
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Validates if the given filetype is compatible to be played with media manager. 
		 *
		 * @param str The file extension to be validated
		 * 
         * @return Boolean of whether the extension was valid or not.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function isValid(str:String):Boolean;
		
		/**
		 * Loads a new file to be played.
		 * 
		 * @param s	The url of the file to be loaded
		 * 
		 * @see cv.events.LoadEvent.LOAD_START
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function load(s:String, autoStart:Boolean):void;
		
		/**
		 * Controls the mute of the audio
		 * 
		 * @default true
		 * 
		 * @param b	Whether to mute or not
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function mute(b:Boolean = true):void;
		
		/**
		 * Controls the pause of the audio
		 * 
		 * @default true
		 * 
		 * @param b	Whether to pause or not
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function pause(b:Boolean = true):void;
		
		/**
		 * Plays the media file, starting at the given position.
		 * 
		 * @default 0
		 * 
		 * @param pos	Position to play from
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function play(pos:int = 0):void;
		
		/**
		 * Seeks to time given in the media file.
		 * 
		 * @param n	Seconds into the file to seek to
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function seek(n:Number):void;
		
		/**
		 * Seeks to the given percent in the media file.
		 * 
		 * @param n	Percent to seek to
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function seekPercent(n:Number):void;
		
		/**
		 * Stops the media file at the specified position. Sets the position given as the pause position.
		 * 
		 * @default 0
		 * 
		 * @param pos	Position to stop at
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function stop(pos:int = 0):void;
		
		/**
		 * Stops the media, closes out any connections, and resets the metadata.
		 * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		function unload():void;
	}
}