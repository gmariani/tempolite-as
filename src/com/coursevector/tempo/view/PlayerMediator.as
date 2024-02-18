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
* @version 0.1
*/

package com.coursevector.tempo.view {
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import flash.events.Event;
	import flash.display.DisplayObject;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.view.events.PlayerEvent;
	import com.coursevector.tempo.view.components.Player;
	import com.coursevector.tempo.interfaces.IMediaProxy;

	public class PlayerMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'PlayerMediator';
		
		private var _repeat:String = PlayerEvent.REPEAT_ALL;
		private var _shuffle:Boolean = false;
		private var _mute:Boolean = false;
		private var _volume:Number = 1;
		private var _scaleMode:String = PlayerEvent.MAINTAIN_ASPECT_RATIO;
		private var player:Player;
		private var strFileName:String = "";
		private var strMetaDataType:String;
		
		public function PlayerMediator(viewComponent:Object) {
			super(NAME, viewComponent);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get cP():IMediaProxy {
			return ApplicationFacade.currentMediaProxy;
		}
		
		public function get scaleMode():String {
			return _scaleMode;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function setSkin(mc:DisplayObject = null):void {
			if (player) {
				player.removeEventListener(PlayerEvent.MUTE, viewHandler);
				player.removeEventListener(PlayerEvent.PAUSE, viewHandler);
				player.removeEventListener(PlayerEvent.PLAY, viewHandler);
				player.removeEventListener(PlayerEvent.STOP, viewHandler);
				player.removeEventListener(PlayerEvent.VOLUME, viewHandler);
				player.removeEventListener(PlayerEvent.SHUFFLE, viewHandler);
				player.removeEventListener(PlayerEvent.REPEAT, viewHandler);
				player.removeEventListener(PlayerEvent.SEEK, viewHandler);
				player.removeEventListener(PlayerEvent.NEXT, viewHandler);
				player.removeEventListener(PlayerEvent.PREVIOUS, viewHandler);
				player.removeEventListener(PlayerEvent.SET_SCREEN, viewHandler);
			}
			
			if (mc != null) {
				player = new Player();
				player.addEventListener(PlayerEvent.SET_SCREEN, viewHandler);
				player.addEventListener(PlayerEvent.MUTE, viewHandler);
				player.addEventListener(PlayerEvent.PAUSE, viewHandler);
				player.addEventListener(PlayerEvent.PLAY, viewHandler);
				player.addEventListener(PlayerEvent.STOP, viewHandler);
				player.addEventListener(PlayerEvent.VOLUME, viewHandler);
				player.addEventListener(PlayerEvent.SHUFFLE, viewHandler);
				player.addEventListener(PlayerEvent.REPEAT, viewHandler);
				player.addEventListener(PlayerEvent.SEEK, viewHandler);
				player.addEventListener(PlayerEvent.NEXT, viewHandler);
				player.addEventListener(PlayerEvent.PREVIOUS, viewHandler);
				player.startUp(mc);
				
				player.title = strFileName;
				player.scaleMode = _scaleMode;
				player.volume = _volume;
				player.mute = _mute;
				player.shuffle = _shuffle;
				player.repeat = _repeat;
				player.trackPosition = cP.currentPercent / 100;
				if (strMetaDataType) {
					if (strMetaDataType == PlayerEvent.AUDIO) {
						player.setAudMetaData(cP.metaData);
					} else if (strMetaDataType == PlayerEvent.VIDEO) {
						player.setVidMetaData(cP.metaData);
					}
				}
			} else {
				player = null;
			}
		}
		
		public function reset():void {
			if(player) player.setStatus();
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [
					ApplicationFacade.AUDIO_METADATA,
					ApplicationFacade.VIDEO_METADATA,
					ApplicationFacade.LOAD_START,
					ApplicationFacade.PLAY_PROGRESS,
					ApplicationFacade.LOAD_PROGRESS,
					ApplicationFacade.NEW_SCALE_MODE
				   ];
		}
		
		override public function handleNotification(note:INotification):void {
			var o:Object = note.getBody();
			
			switch (note.getName())	{
				case ApplicationFacade.AUDIO_METADATA :
					strMetaDataType = PlayerEvent.AUDIO;
					if(player) player.setAudMetaData(note.getBody());
					break;
				case ApplicationFacade.VIDEO_METADATA :
					strMetaDataType = PlayerEvent.VIDEO;
					if(player) player.setVidMetaData(note.getBody());
					break;
				case ApplicationFacade.LOAD_START :
					var strURL:String = o.url;
					var arrURL:Array = (strURL.indexOf("\\") != -1) ? strURL.split("\\") : strURL.split("/");
					strFileName = arrURL[arrURL.length - 1];
					strMetaDataType = null;
					
					if (player) {
						if (o.type == "audio") player.goNormalScreen();
						reset();
						player.title = strFileName;
						player.timeTotal = o.time;
						player.start();
					}
					break;
				case ApplicationFacade.PLAY_PROGRESS :
					if(player) {
						if (player.getStatus() != PlayerEvent.PLAY) player.setStatus(PlayerEvent.PLAY);
						player.timeTotal = o.total;
						player.time = o.elapsed;
						player.time2 = o.remain;
						player.trackPosition = o.percent / 100;
					}
					break;
				case ApplicationFacade.LOAD_PROGRESS :
					if(player) player.loadProgress = o;
					break;
				case ApplicationFacade.NEW_SCALE_MODE :
					_scaleMode = String(o);
					if(player) player.scaleMode = _scaleMode;
					break;
			}
			
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function viewHandler(e:Event):void {
			switch(e.type) {
				case PlayerEvent.PLAY :
					sendNotification(ApplicationFacade.PLAY);
					break;
				case PlayerEvent.STOP :
					sendNotification(ApplicationFacade.STOP);
					break;
				case PlayerEvent.PAUSE :
					sendNotification(ApplicationFacade.PAUSE, true);
					break;
				case PlayerEvent.VOLUME :
					_volume = player.volume
					sendNotification(ApplicationFacade.VOLUME, _volume);
					if(_mute == true) {
						player.mute = _mute = false;
						sendNotification(ApplicationFacade.MUTE, _mute);
					}
					break;
				case PlayerEvent.REPEAT :
					if(_repeat == PlayerEvent.REPEAT_NONE) {
						_repeat = PlayerEvent.REPEAT_ALL;
					} else if(_repeat == PlayerEvent.REPEAT_ALL) {
						_repeat = PlayerEvent.REPEAT_TRACK;
					} else {
						_repeat = PlayerEvent.REPEAT_NONE;
					}
					
					player.repeat = _repeat;
					sendNotification(ApplicationFacade.REPEAT_PLAYLIST, _repeat);
					break;
				case PlayerEvent.SHUFFLE :
					_shuffle = !_shuffle;
					player.shuffle = _shuffle;
					sendNotification(ApplicationFacade.SHUFFLE_PLAYLIST, _shuffle);
					break;
				case PlayerEvent.MUTE :
					_mute = !_mute;
					player.mute = _mute;
					sendNotification(ApplicationFacade.MUTE, _mute);
					break;
				case PlayerEvent.NEXT :
					sendNotification(ApplicationFacade.NEXT);
					break;
				case PlayerEvent.PREVIOUS :
					sendNotification(ApplicationFacade.PREVIOUS);
					break;
				case PlayerEvent.SEEK :
					sendNotification(ApplicationFacade.SEEK, player.trackPosition);
					break;
				case PlayerEvent.SET_SCREEN :
					sendNotification(ApplicationFacade.SET_VIDEO, player.video);
					break;
			}
		}
	}
}