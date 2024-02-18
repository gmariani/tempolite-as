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
* Manages loading and sending skins to the other mediators
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.tempo.view {
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.view.PlayerMediator;
	import com.coursevector.tempo.view.PlayListMediator;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class SkinMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'SkinMediator';
		
		private var skinLoader:Loader;
		private var mcSkin:DisplayObjectContainer;
		private var pM:PlayerMediator;
		private var plM:PlayListMediator;
		private var _holder:Sprite = new Sprite();
		
		public function SkinMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			DisplayObjectContainer(viewComponent).addChild(holder);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get holder():Sprite {
			return _holder;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			pM = new PlayerMediator(holder);
			facade.registerMediator(pM);
			
			plM = new PlayListMediator(holder);
			facade.registerMediator(plM);
		} 
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.NEW_SKIN];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				case ApplicationFacade.NEW_SKIN :
					loadSkin(note.getBody() as String);
					break;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function ioErrorHandler(e:IOErrorEvent):void {
			trace("SkinMediator::loadSkin - " + e.text);
        }
		
		private function loadSkin(s:String):void {
			if (mcSkin) holder.removeChild(mcSkin);
			
			skinLoader = new Loader();
			skinLoader.load(new URLRequest(s));
			skinLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, skinLoadedHandler);
			skinLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function skinLoadedHandler(e:Event):void {
			mcSkin = skinLoader.content as DisplayObjectContainer;
			pM.setSkin(mcSkin.getChildByName(ApplicationFacade.PLAYER));
			plM.setSkin(mcSkin.getChildByName(ApplicationFacade.PLAY_LIST));
			holder.addChild(mcSkin);
		}
	}
}