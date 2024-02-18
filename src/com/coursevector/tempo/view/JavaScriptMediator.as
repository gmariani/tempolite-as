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
* Handles all ExternalInterface calls for Tempo
* 
* @author Gabriel Mariani
* @version 0.1
*/

/*
TODO: 

-Methods
loadFile(obj:PlayListObject) : {file:url, image:url/image, captions:url/xml}, file, image, id, link, type, captions, audio, title, author
mute()
unmute()

-Properties
setScrubPercent[, percent]
getScrubPercent
getPlayerState
*/

package com.coursevector.tempo.view {
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.view.APIMediator;
	
	import flash.external.ExternalInterface;
	
	public class JavaScriptMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'JavaScriptMediator';
		private var api:APIMediator;
		
		public function JavaScriptMediator(viewComponent:Object) {
            super(NAME, viewComponent);
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			init();
		}
		
		override public function listNotificationInterests():Array {
			return [
					ApplicationFacade.PLAY_PROGRESS,
					ApplicationFacade.PLAY_COMPLETE,
					ApplicationFacade.LOAD_START,
					ApplicationFacade.LOAD_PROGRESS,
					ApplicationFacade.AUDIO_METADATA,
					ApplicationFacade.VIDEO_METADATA,
					ApplicationFacade.REFRESH_PLAYLIST,
					ApplicationFacade.NEW_PLAYLIST
				   ];
		}
		
		override public function handleNotification(note:INotification):void {
			var o:Object = note.getBody();
			
			switch (note.getName())	{
				case ApplicationFacade.PLAY :
					ExternalInterface.call("onPlay");
					break;
				case ApplicationFacade.AUDIO_METADATA :
				case ApplicationFacade.VIDEO_METADATA :
					ExternalInterface.call("onMetaData", o);
					break;
				case ApplicationFacade.PLAY_PROGRESS :
					ExternalInterface.call("onPlayProgress", o);
					break;
				case ApplicationFacade.PLAY_COMPLETE :
					ExternalInterface.call("onPlayComplete");
					break;
				case ApplicationFacade.LOAD_START :
					ExternalInterface.call("onLoad", o);
					break;
				case ApplicationFacade.LOAD_PROGRESS :
					ExternalInterface.call("onLoadProgress", o);
					break;
				case ApplicationFacade.VOLUME :
					ExternalInterface.call("onVolume", o);
					break;
				case ApplicationFacade.SHUFFLE_PLAYLIST :
					ExternalInterface.call("onShuffle", o);
					break;
				case ApplicationFacade.REPEAT_PLAYLIST :
					ExternalInterface.call("onRepeat", o);
					break;
			}
		}
		
		private function init():void {
			api = facade.retrieveMediator(APIMediator.NAME) as APIMediator;
			
			if (ExternalInterface.available) {
                try {
					// Methods
					ExternalInterface.addCallback("play", 				api.play);
					ExternalInterface.addCallback("playpause", 			api.pause);
					ExternalInterface.addCallback("pause", 				api.pause);
					ExternalInterface.addCallback("stop", 				api.stop);
					ExternalInterface.addCallback("next", 				api.next);
					ExternalInterface.addCallback("prev", 				api.previous);
					ExternalInterface.addCallback("playItem", 			api.play); // (idx:int)
					ExternalInterface.addCallback("loadFile", 			api.loadMedia); 	// (url:String, autoStart:Boolean = true)
																							// (obj:PlayListObject) : {file:url, image:url/image, captions:url/xml}, file, image, id, link, type, captions, audio, title, author
					ExternalInterface.addCallback("addItem", 			api.addItem); 	// PlayListObject {url:String, title:String = "", length:int = -1}
																						// (obj:PlayListObject, idx:Number) : Add item to end of playlist if idx isn't there
					ExternalInterface.addCallback("removeItem", 		api.removeItem); // (idx:number) : Remove item, last item removed if idx isn't there
					ExternalInterface.addCallback("clearItems", 		api.clearItems);
					ExternalInterface.addCallback("mute", 				api.setMute); // (b:Boolean)
					ExternalInterface.addCallback("loadSkin", 			api.loadSkin); // (str:String = "DefaultSkin.swf")
					ExternalInterface.addCallback("loadPlayList", 		api.loadPlayList); // (str:String = "playlists/Tempo.m3u")
					
					// Properties
					ExternalInterface.addCallback("setId", 				setId); // Number
					ExternalInterface.addCallback("getId", 				function(){return api.id});
					ExternalInterface.addCallback("setRepeat", 			setRepeat); // (bool)
					ExternalInterface.addCallback("getRepeat", 			function(){return api.repeat});
					ExternalInterface.addCallback("setShuffle", 		setShuffle); // (bool)
					ExternalInterface.addCallback("getShuffle", 		function(){return api.shuffle});
					ExternalInterface.addCallback("setVolume", 			setVolume); // [, percent]
					ExternalInterface.addCallback("getVolume", 			function() { return api.volume } );
					//ExternalInterface.addCallback("setSeekTime", 		setSeekTime); // [, seconds]
					//ExternalInterface.addCallback("getSeekTime", 		mP.timeCurrent); // BUG: can't add becuase this is specific to the player view and can't be accessed by TempoLite
					ExternalInterface.addCallback("setSeekPercent", 	api.seekPercent); //[, percent]
					ExternalInterface.addCallback("getSeekPercent", 	function(){return api.getCurrentPercent()});
					ExternalInterface.addCallback("getItemData", 		function(){return api.getList().getCurrent()}); // Returns playlist object data
					ExternalInterface.addCallback("getItemIndex", 		function(){return api.getList().index});
					ExternalInterface.addCallback("getLength", 			function(){return api.getList().length}); // Playlist Length
					ExternalInterface.addCallback("getLoadPercent", 	function(){return (api.getLoadCurrent() / api.getLoadTotal()) * 100});
					//ExternalInterface.addCallback("getPlayerState", 	receivedFromJavaScript);
					ExternalInterface.addCallback("getTimeElapsed", 	function(){return api.getTimeCurrent()});
					ExternalInterface.addCallback("getTimeRemaining", 	function(){return api.getTimeLeft()});
					
					ExternalInterface.addCallback("getObjectID", 		function(){return ExternalInterface.objectID}); // Unique SWF object ID in the html
                } catch (error:SecurityError) {
					trace("JavaScriptMediator::init - " + error.message);
                } catch (error:Error) {
					trace("JavaScriptMediator::init - " + error.message);
                }
            } else {
                trace("JavaScriptMediator::init - Error : External interface is not available.");
            }
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function setId(n:String):void {	api.id = n }
		private function setVolume(n:Number):void { api.volume = n }
		private function setShuffle(b:Boolean):void { api.shuffle = b }
		private function setRepeat(str:String):void { api.repeat = str }
		// BUG: can't add becuase this is specific to the player view and can't be accessed by TempoLite
		//private function setSeekTime(n:Number):void {	api.seek(n) }
	}
}