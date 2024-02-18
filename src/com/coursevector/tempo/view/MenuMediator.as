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
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.tempo.ApplicationFacade;
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	public class MenuMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'MenuMediator';
		
		public function MenuMediator(viewComponent:Object) {
            super(NAME, viewComponent);
			
			var item:ContextMenuItem = new ContextMenuItem("Tempo - v" + ApplicationFacade.VERSION);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, aboutHandler);
			
			var c:ContextMenu = new ContextMenu();
			c.hideBuiltInItems();
			c.customItems.push(item);
			viewComponent.contextMenu = c;
		}
		
		private function aboutHandler(event:ContextMenuEvent):void {
			navigateToURL(new URLRequest("http://labs.coursevector.com/wiki/index.php?title=Tempo"));
		}
	}
}