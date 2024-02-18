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
	import flash.display.DisplayObjectContainer;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.view.components.PlayListEditor;
	import com.coursevector.tempo.model.PlayListProxy;

	public class PlayListMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'PlayListMediator';
		
		private var plP:PlayListProxy;
		private var ple:PlayListEditor;
		
		public function PlayListMediator(viewComponent:Object) {
			super(NAME, viewComponent);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get playListProxy():PlayListProxy {
			if(!plP) plP = facade.retrieveProxy(PlayListProxy.NAME) as PlayListProxy;
			return plP;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function setSkin(mc:DisplayObjectContainer = null):void {
			if (ple) ple.removeEventListener(ApplicationFacade.CHANGE, viewHandler);
			
			if (mc) {
				ple = new PlayListEditor(mc);
				ple.list = playListProxy.list;
				ple.addEventListener(ApplicationFacade.CHANGE, viewHandler);
			} else {
				ple = null;
			}
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.AUDIO_METADATA,
					ApplicationFacade.PLAY_PROGRESS,
					ApplicationFacade.REFRESH_PLAYLIST,
					ApplicationFacade.NEW_PLAYLIST];
		}
		
		override public function handleNotification(note:INotification):void {
			var o:Object = note.getBody();
			switch (note.getName())	{
				case ApplicationFacade.AUDIO_METADATA :
					if ((o.artist || o.TPE1) && (o.songname || o.TIT2)) {
						playListProxy.updateItemTitle(playListProxy.list.index, (!o.artist ? o.TPE1 : o.artist) + " - " + (!o.songname ? o.TIT2 : o.songname));
						if (o.TLEN) playListProxy.updateItemLength(playListProxy.list.index, o.TLEN);
						if (ple) ple.refreshPlayList();
					}
					break;
				/*case ApplicationFacade.PLAY_PROGRESS :
					playListProxy.updateItemLength(playListProxy.list.index, o.total);
					//if (ple) ple.refreshPlayList();
					break;*/
				case ApplicationFacade.NEW_PLAYLIST :
					if (ple) ple.list = playListProxy.list;
					break;
				case ApplicationFacade.REFRESH_PLAYLIST :
					if (ple) ple.refreshPlayList();
					break;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function viewHandler(e:Event):void {
			playListProxy.list.index = ple.selectedIndex;
			sendNotification(ApplicationFacade.LOAD, playListProxy.list.getCurrent());
		}
	}
}