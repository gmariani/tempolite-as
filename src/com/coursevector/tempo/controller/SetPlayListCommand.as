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
* Manages all settings pertaining to the PlayListProxy
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.tempo.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.model.PlayListProxy;
	import com.coursevector.tempo.view.events.PlayerEvent;
	import com.coursevector.data.PlayList;
	
	public class SetPlayListCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var p:PlayListProxy = facade.retrieveProxy(PlayListProxy.NAME) as PlayListProxy;
			var o:Object = note.getBody();
			
			switch(note.getName()) {
				case ApplicationFacade.AUTO_START :
					p.autoStart = o;
					break;
				case ApplicationFacade.AUTO_START_INDEX :
					p.autoStartIndex = o as int;
					break;
				case ApplicationFacade.SHUFFLE_PLAYLIST :
					p.shuffle = o;
					break;
				case ApplicationFacade.REPEAT_PLAYLIST :
					p.repeat = o as String;
					break;
				case ApplicationFacade.LOAD_PLAYLIST :
					p.load(o as String);
					break;
				case ApplicationFacade.NEW_PLAYLIST :
					if (p.autoStart) {
						var l:PlayList = p.list;
						l.index = p.autoStartIndex;
						if(l.getCurrent()) sendNotification(ApplicationFacade.LOAD, l.getCurrent());
					}
					break;
				case ApplicationFacade.NEXT :
					o = p.getNext();
					if (o != null) sendNotification(ApplicationFacade.LOAD, o);
					break;
				case ApplicationFacade.PREVIOUS :
					o = p.getPrevious();
					if (o != null) sendNotification(ApplicationFacade.LOAD, o);
					break;
				case ApplicationFacade.ADD_ITEM :
					o = note.getBody();
					p.addItem(o.item, o.index);
					break;
				case ApplicationFacade.REMOVE_ITEM :
					p.removeItem(o as int);
					break;
				case ApplicationFacade.CLEAR_PLAYLIST :
					p.clear();
					break;
				case ApplicationFacade.AUDIO_METADATA :
					if (o.TLEN) p.updateItemLength(p.list.index, o.TLEN);
					break;
				case ApplicationFacade.VIDEO_METADATA :
					if (o.duration) p.updateItemLength(p.list.index, o.duration * 1000);
					break;
			}
		}
	}
}