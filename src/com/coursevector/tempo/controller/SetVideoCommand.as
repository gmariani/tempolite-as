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

package com.coursevector.tempo.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.tempo.interfaces.IVideoProxy;
	
	import flash.media.Video;

	public class SetVideoCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var v:IVideoProxy = facade.retrieveProxy("VideoProxy") as IVideoProxy;
			if(v) v.video = note.getBody() as Video;
		}
	}
}