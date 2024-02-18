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
 * A stripped down version of Tempo for use in the IDE, called TempoLite
 * 
 * @author Gabriel Mariani
 * @version 1.0.1
 * 
 * Prop
 * checkForPolicyFile:Boolean
 */

package com.coursevector.tempo {

	import com.coursevector.tempo.controller.StartupLiteCommand;
	import com.coursevector.tempo.model.PlayListProxy;
	import com.coursevector.tempo.view.APIMediator;
	import com.coursevector.tempo.view.events.PlayerEvent;
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.data.PlayList;
	
	import flash.media.Video;
	import flash.display.Sprite;
	import flash.events.Event;
    
    public class TempoLite extends Sprite {
		
		public static const PLAY_START:String = ApplicationFacade.PLAY_START;
		public static const PLAY_PROGRESS:String = ApplicationFacade.PLAY_PROGRESS;
		public static const PLAY_COMPLETE:String = ApplicationFacade.PLAY_COMPLETE;
		public static const NEXT:String = ApplicationFacade.NEXT;
		public static const PREVIOUS:String = ApplicationFacade.PREVIOUS;
		public static const LOAD_START:String = ApplicationFacade.LOAD_START;
		public static const LOAD_PROGRESS:String = ApplicationFacade.LOAD_PROGRESS;
		public static const VIDEO_METADATA:String = ApplicationFacade.VIDEO_METADATA;
		public static const AUDIO_METADATA:String = ApplicationFacade.AUDIO_METADATA;
		public static const REFRESH_PLAYLIST:String = ApplicationFacade.REFRESH_PLAYLIST;
		public static const NEW_PLAYLIST:String = ApplicationFacade.NEW_PLAYLIST;
		public static const CHANGE:String = ApplicationFacade.CHANGE;
		public static const REPEAT_TRACK:String = PlayerEvent.REPEAT_TRACK;
		public static const REPEAT_ALL:String = PlayerEvent.REPEAT_ALL;
		public static const REPEAT_NONE:String = PlayerEvent.REPEAT_NONE;
		
		// Settings
		private var vidScreen:Video;
		private var screenWidth:Number;
		private var screenHeight:Number;
		private var screenX:Number;
		private var screenY:Number;
		private var appFcd:ApplicationFacade; 
		private var api:APIMediator;
		
		/**
		 * Constructor. 
		 * 
		 * <P>
		 * This creates a new TempoLite instance.
		 * 
		 */
		public function TempoLite() {
			init();
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
		public function get autoStart():Boolean { return api.autoStart }
		public function set autoStart(b:Boolean):void { api.autoStart = b }
		
		/** 
		 * If autoStart is true, the index of the item in the playlist to play first.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get autoStartIndex():int { return api.autoStartIndex }
		public function set autoStartIndex(n:int):void { api.autoStartIndex = n }
		
		/** 
		 * The time in seconds to buffer a file before playing.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get bufferTime():int { return api.bufferTime }
		public function set bufferTime(n:int):void { api.bufferTime = n }
		
		/** 
		 * If TempoLite is currently paused.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get isPause():Boolean { return api.isPause }
		
		/** 
		 * Retrieves the number of items in the playlist.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get length():uint { return api.getList().length }
		
		/** 
		 * @private Retrieves the playlist proxy.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		private function get playListProxy ():PlayListProxy {
			return appFcd.retrieveProxy(PlayListProxy.NAME) as PlayListProxy;
		}
		
		/** 
		 * Whether to loop the playlist, single item, or not at all. Acceptable values are 
		 * 
		 * TempoLite.REPEAT_TRACK = "track"
		 * TempoLite.REPEAT_ALL = "all"
		 * TempoLite.REPEAT_NONE = "none"
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get repeat():String { return api.repeat }
		public function set repeat(str:String):void { api.repeat = str }
		
		/** 
		 * Whether to shuffle the playlist or not (default false).
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get shuffle():Boolean { return api.shuffle }
		public function set shuffle(b:Boolean):void { api.shuffle = b }
		
		/** 
		 * The version of TempoLite in use.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public static function get version():String { return ApplicationFacade.VERSION }
		
		/** 
		 * A number from 0 to 1 determines volume (default 0.5).
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get volume():Number { return api.volume }
		public function set volume(n:Number):void { api.volume = n }
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Add an item to the playlist at the end, or at index specified.
		 * 
		 * @param item	item to be added.
		 * @param index where the item should be added in the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function addItem(item:Object, index:int = -1):void { api.addItem(item, index) }
		
		/**
		 * Clears the current playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function clearItems():void {	api.clearItems() }
		
		/**
		 * Retrieve the current play progress as a percent.
		 * 
		 * @return the play progress in terms of percent.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getCurrentPercent():uint { return api.getCurrentPercent() }
		
		/**
		 * Retrieve the current item playing.
		 * 
		 * @return the current item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getCurrentItem():Object { return api.getList().getCurrent() }
		
		/**
		 * Retrieve the current index in the playlist.
		 * 
		 * @return the index of the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getCurrentIndex():uint { return api.getList().index	}
		
		/**
		 * Retrieve the metadata from the current item playing if available.
		 * 
		 * @return the metadata associated with the item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getMetaData():Object { return api.getMetaData() }
		
		/**
		 * Retrieve the total play time of the current item playing.
		 * 
		 * @return the total play time of the item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getTimeTotal():String {	return api.getTimeTotal() }
		
		/**
		 * Retrieve the current play time of the current item playing.
		 * 
		 * @return the current play time of the item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getTimeCurrent():String { return api.getTimeCurrent() }
		
		/**
		 * Retrieve the play time remaining of the current item playing.
		 * 
		 * @return the play time remaining of the item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getTimeLeft():String { return api.getTimeLeft() }
		
		/**
		 * Retrieve the total bytes to load of the current item.
		 * 
		 * @return the total bytes to load of the item.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getLoadTotal():Number {	return api.getLoadTotal() }
		
		/**
		 * Retrieve the current bytes loaded of the current item.
		 * 
		 * @return the current bytes loaded of the item.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getLoadCurrent():Number { return api.getLoadCurrent() }
		
		/**
		 * Retrieve the current playlist in <code>PlayList</code> format (enhanced array).
		 * 
		 * @return the playlist as a <code>PlayList</code> type.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function getList():PlayList { return api.getList() }
		
		/**
		 * Create a playlist of a single item and load the item.
		 * 
		 * @param item item to be played.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function loadMedia(item:Object, autoStart:Boolean = true):void { api.loadMedia(item, autoStart) }
		
		/**
		 * Unloads the current item playing. 
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function unloadMedia():void { api.unloadMedia() }
		
		/**
		 * Loads a new playlist and clears any previous playlsit.
		 * 
		 * @param url the path to the playlist file.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function loadPlayList(url:String = null):void { api.loadPlayList(url) }
		
		/**
		 * Plays the next item in the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function next():void { api.next() }
		
		/**
		 * Pauses the current playback.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function pause(b:Boolean = true):void { api.pause(b) }
		
		/**
		 * Plays the current item in the playlist, or at the 
		 * specified index in the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function play(index:int = -1):void { api.play(index) }
		
		/**
		 * Plays the previous item in the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function previous():void { api.previous() }
		
		/**
		 * Remove an item from the playlist from the end, or at index specified.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function removeItem(index:int = -1):void {	api.removeItem(index) }
		
		/**
		 * Seek to a specific time (in seconds) in the current item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seek(time:Number):void { api.seek(time) }
		
		/**
		 * Seek to a specific percent (0 - 1) in the current item playing.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seekPercent(percent:Number):void { api.seekPercent(percent) }
		
		/**
		 * Seek by the amount (in seconds) specified relative to the current play time.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function seekRelative(time:Number):void { api.seekRelative(time) }
		
		/**
		 * Toggles mute.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function setMute(b:Boolean):void { api.setMute(b) }
		
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
			appFcd.sendNotification(ApplicationFacade.SET_VIDEO, vidScreen);
		}
		
		/**
		 * Determines how TempoLite will scale a video. The options are 
		 * 
		 * TempoLite.MAINTAIN_ASPECT_RATIO = "maintainAspectRatio"
		 * TempoLite.EXACT_FIT = "exactFit"
		 * TempoLite.NO_SCALE = "noScale"
		 * 
		 * @param scaleMode scale mode to use for video scaling.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function setVideoScale(scaleMode:String):void {
			if (vidScreen) {
				
				switch(scaleMode) {
					case PlayerEvent.MAINTAIN_ASPECT_RATIO :
					case PlayerEvent.EXACT_FIT :
					case PlayerEvent.NO_SCALE :
						break;
					default :
						return;
				}
				
				var vidW:int = vidScreen.videoWidth;
				var vidH:int = vidScreen.videoHeight;
				switch (scaleMode) {
					case PlayerEvent.NO_SCALE :
						vidScreen.width = vidW;
						vidScreen.height = vidH;
						vidScreen.x = screenX;
						vidScreen.y = screenY;
						break;
					case PlayerEvent.EXACT_FIT :
						vidScreen.width = screenWidth;
						vidScreen.height = screenHeight;
						vidScreen.x = screenX;
						vidScreen.y = screenY;
						break;
					case PlayerEvent.MAINTAIN_ASPECT_RATIO :
					default:
						var newWidth:Number = (vidW * screenHeight / vidH);
						var newHeight:Number = (vidH * screenWidth / vidW);
						if (newHeight < screenHeight) {
							vidScreen.width = screenWidth;
							vidScreen.height = newHeight;
						} else if (newWidth < screenWidth) {
							vidScreen.width = newWidth;
							vidScreen.height = screenHeight;
						} else {
							vidScreen.width = screenWidth;
							vidScreen.height = screenHeight;
						}
						
						vidScreen.x = screenX + ((screenWidth - vidScreen.width) / 2);
						vidScreen.y = screenY + ((screenHeight - vidScreen.height) / 2);
				}
			}
		}
		
		/**
		 * Stops the selected item in the playlist.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function stop():void { api.stop() }
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function apiHandler(e:Event):void {
			if (e.type == ApplicationFacade.NEW_PLAYLIST) {
				playListProxy.list.removeEventListener(PlayList.CHANGE, playlistHandler);
				playListProxy.list.addEventListener(PlayList.CHANGE, playlistHandler);
			}
			
			dispatchEvent(e.clone());
		}
		
		private function init():void {
			appFcd = ApplicationFacade.getInstance("TempoLite");
			appFcd.registerCommand(ApplicationFacade.STARTUP, StartupLiteCommand);
			//api = appFcd.retrieveMediator(APIMediator.NAME) as APIMediator;
			api = new APIMediator();
			api.addEventListener(ApplicationFacade.PLAY_START, apiHandler);
			api.addEventListener(ApplicationFacade.PLAY_PROGRESS, apiHandler);
			api.addEventListener(ApplicationFacade.PLAY_COMPLETE, apiHandler);
			api.addEventListener(ApplicationFacade.NEXT, apiHandler);
			api.addEventListener(ApplicationFacade.PREVIOUS, apiHandler);
			api.addEventListener(ApplicationFacade.LOAD_START, apiHandler);
			api.addEventListener(ApplicationFacade.LOAD_PROGRESS, apiHandler);
			api.addEventListener(ApplicationFacade.VIDEO_METADATA, apiHandler);
			api.addEventListener(ApplicationFacade.AUDIO_METADATA, apiHandler);
			api.addEventListener(ApplicationFacade.REFRESH_PLAYLIST, apiHandler);
			api.addEventListener(ApplicationFacade.NEW_PLAYLIST, apiHandler);
			
			appFcd.startup(this);
			appFcd.registerMediator(api);
		}
		
		private function playlistHandler(e:Event):void {
			dispatchEvent(e.clone());
		}
    }
}