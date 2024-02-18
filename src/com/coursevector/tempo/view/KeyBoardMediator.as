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
	
	import flash.events.KeyboardEvent;
	
	public class KeyBoardMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'KeyBoardMediator';
		
		public function KeyBoardMediator(viewComponent:Object) {
            super(NAME, viewComponent);
			
			viewComponent.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		}
		
		private function keyHandler(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case 32 :
					// Space
					sendNotification(ApplicationFacade.PAUSE);
					break;
				case 37 :
					// Left Arrow
					//if (feeder.feed.length == 1) {
					//	sendNotification(ApplicationFacade.SEEK_RELATIVE, -15); // one item
					//} else {
						sendNotification(ApplicationFacade.PREVIOUS);
					//}
					break;
				case 39 :
					// Right Arrow
					//if (feeder.feed.length == 1) {
					//	sendNotification(ApplicationFacade.SEEK_RELATIVE, 15); // one item
					//} else {
						sendNotification(ApplicationFacade.NEXT);
					//}
					break;
				case 38 :
					// Up Arrow
					sendNotification(ApplicationFacade.VOLUME_RELATIVE, .1);
					break;
				case 40 :
					// Down Arrow
					sendNotification(ApplicationFacade.VOLUME_RELATIVE, -.1);
					break;
				case 77 :
					sendNotification(ApplicationFacade.MUTE, true);
					break;
			}
		}
	}
}