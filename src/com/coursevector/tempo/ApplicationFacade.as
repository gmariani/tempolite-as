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
* ...
* @author Gabriel Mariani
* @version 1.0.0
*/

package com.coursevector.tempo {
	
	import com.coursevector.tempo.interfaces.IMediaProxy;
	import flash.display.DisplayObjectContainer;
    import org.puremvc.as3.multicore.interfaces.IFacade;
    import org.puremvc.as3.multicore.patterns.facade.Facade;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	
	//import com.coursevector.tempo.controller.StartupCommand;
	import com.coursevector.tempo.controller.SetMediaCommand;
	import com.coursevector.tempo.controller.SetPlayListCommand;
    
    public class ApplicationFacade extends Facade implements IFacade {
		
		public static const VERSION:String = "1.0.4";
		
        // Notification name constants
        public static const STARTUP:String = "startup";
        public static const INITIALIZED:String = "initialized";
        public static const NEW_SKIN:String = "newSkin";
        public static const CHANGE:String = "change";
		
		// Audio/Video Proxy
		public static const BUFFER:String = "buffer";
		public static const PLAY_START:String = "playStart";
		public static const PLAY_PROGRESS:String = "playProgress";
		public static const PLAY_COMPLETE:String = "playComplete";
		public static const LOAD_START:String = "loadStart";
		public static const LOAD_PROGRESS:String = "loadProgres";
		public static const LOAD_COMPLETE:String = "loadComplete";
		public static const VIDEO_METADATA:String = "videoMetadata";
		public static const AUDIO_METADATA:String = "audioMetadata";
		
		// Playlist Proxy
		public static const AUTO_START:String = "autoStart";
        public static const AUTO_START_INDEX:String = "autoStartIndex";
		public static const NEXT:String = "next";
		public static const PREVIOUS:String = "prev";
		public static const CHANGE_PLAYLIST:String = "changePlaylist";
		public static const REFRESH_PLAYLIST:String = "refreshPlaylist";
		public static const LOAD_PLAYLIST:String = "loadPlaylist";
		public static const NEW_PLAYLIST:String = "newPlaylist";
		public static const SHUFFLE_PLAYLIST:String = "shufflePlaylist";
		public static const REPEAT_PLAYLIST:String = "repeatPlaylist";
		public static const ADD_ITEM:String = "addItem";
		public static const REMOVE_ITEM:String = "removeItem";
		public static const CLEAR_PLAYLIST:String = "clearPlaylist";
		
		// Player
		public static const NEW_SCALE_MODE:String = "newScaleMode";
		public static const MUTE:String = "mute";
		public static const SEEK:String = "seek";
		public static const SEEK_TIME:String = "seekTime";
		public static const SEEK_RELATIVE:String = "seekRelative";
		public static const PLAY:String = "play";
		public static const LOAD:String = "load";
		public static const UNLOAD:String = "unload";
		public static const VOLUME:String = "volume";
		public static const VOLUME_RELATIVE:String = "volumeRelative";
		public static const PAUSE:String = "pause";
		public static const STOP:String = "stop";
		public static const SET_VIDEO:String = "setVideo";
		
		// Skin Mediator
		public static const PLAYER:String = 'player'; // Default name
		public static const PLAY_LIST:String = 'playlist'; // Default name
		
		private static var _cP:IMediaProxy;
		
		public function ApplicationFacade(key:String) {
			super(key);	
		}
		
		public static function get currentMediaProxy():IMediaProxy { return _cP }
		public static function set currentMediaProxy(value:IMediaProxy):void { _cP = value }
		
		/**
         * Singleton ApplicationFacade Factory Method
         */
        public static function getInstance(key:String):ApplicationFacade {
            if (instanceMap[key] == null) instanceMap[key] = new ApplicationFacade(key);
            return instanceMap[key] as ApplicationFacade;
        }
		
		/**
         * Application startup
         * 
         * @param app a reference to the application component 
         */  
        public function startup(app:DisplayObjectContainer):void {
        	sendNotification(ApplicationFacade.STARTUP, app);
        }
		
        override protected function initializeController():void {
			super.initializeController();
			
			//registerCommand(ApplicationFacade.STARTUP, 			StartupCommand);
			registerCommand(ApplicationFacade.PLAY, 			SetMediaCommand);
			registerCommand(ApplicationFacade.LOAD, 			SetMediaCommand);
			registerCommand(ApplicationFacade.UNLOAD, 			SetMediaCommand);
			registerCommand(ApplicationFacade.MUTE, 			SetMediaCommand);
			registerCommand(ApplicationFacade.SEEK, 			SetMediaCommand);
			registerCommand(ApplicationFacade.SEEK_TIME, 		SetMediaCommand);
			registerCommand(ApplicationFacade.SEEK_RELATIVE, 	SetMediaCommand);
			registerCommand(ApplicationFacade.STOP, 			SetMediaCommand);
			registerCommand(ApplicationFacade.PAUSE, 			SetMediaCommand);
			registerCommand(ApplicationFacade.VOLUME, 			SetMediaCommand);
			registerCommand(ApplicationFacade.VOLUME_RELATIVE, 	SetMediaCommand);
			registerCommand(ApplicationFacade.BUFFER, 			SetMediaCommand);
			registerCommand(ApplicationFacade.AUTO_START, 		SetPlayListCommand);
			registerCommand(ApplicationFacade.AUTO_START_INDEX, SetPlayListCommand);
			registerCommand(ApplicationFacade.NEW_PLAYLIST, 	SetPlayListCommand);
			registerCommand(ApplicationFacade.SHUFFLE_PLAYLIST, SetPlayListCommand);
			registerCommand(ApplicationFacade.REPEAT_PLAYLIST, 	SetPlayListCommand);
			registerCommand(ApplicationFacade.LOAD_PLAYLIST, 	SetPlayListCommand);
			registerCommand(ApplicationFacade.NEXT, 			SetPlayListCommand);
			registerCommand(ApplicationFacade.PREVIOUS, 		SetPlayListCommand);
			registerCommand(ApplicationFacade.ADD_ITEM, 		SetPlayListCommand);
			registerCommand(ApplicationFacade.REMOVE_ITEM, 		SetPlayListCommand);
			registerCommand(ApplicationFacade.CLEAR_PLAYLIST, 	SetPlayListCommand);
			registerCommand(ApplicationFacade.AUDIO_METADATA, 	SetPlayListCommand);
			registerCommand(ApplicationFacade.VIDEO_METADATA, 	SetPlayListCommand);
			registerCommand(ApplicationFacade.SET_VIDEO, 		SetMediaCommand);
        }
    }
}