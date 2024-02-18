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
* Manages all settings pertaining to the Media Proxys
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.tempo.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import flash.media.Video;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.interfaces.IMediaProxy;
	import com.coursevector.tempo.interfaces.IVideoProxy;

	public class SetMediaCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var aP:IMediaProxy = facade.retrieveProxy("AudioProxy") as IMediaProxy;
			var vP:IMediaProxy = facade.retrieveProxy("VideoProxy") as IMediaProxy;
			var cP:IMediaProxy = ApplicationFacade.currentMediaProxy;
			var o:Object = note.getBody();
			
			switch(note.getName()) {
				case ApplicationFacade.MUTE :
					if(aP) aP.mute(o);
					if(vP) vP.mute(o);
					break;
				case ApplicationFacade.LOAD :
					var ext:String = o.extOverride || o.url.substr( -3).toLowerCase();
					if (aP) { aP.unLoad() }
					if (vP) { vP.unLoad() }
					
					if (aP && aP.isValid(ext)) {
						ApplicationFacade.currentMediaProxy = aP;
						aP.load(o.url);
					} else if (vP.isValid(ext) && vP) {
						ApplicationFacade.currentMediaProxy = vP;
						vP.load(o.url);
					}
					break;
				case ApplicationFacade.UNLOAD :
					if(aP) aP.unLoad();
					if(vP) vP.unLoad();
					break;
				case ApplicationFacade.PAUSE :
					if (o == null) o = true;
					cP.pause(o);
					break;
				case ApplicationFacade.PLAY :
					cP.play();
					break;
				case ApplicationFacade.SEEK :
					cP.seekPercent(Number(o) * 100);
					break;
				case ApplicationFacade.SEEK_TIME :
					cP.seek(Number(o) * 1000);
					break;
				case ApplicationFacade.SEEK_RELATIVE :
					cP.seek(cP.timeCurrent + (Number(o) * 1000));
					break;
				case ApplicationFacade.STOP :
					cP.stop();
					break;
				case ApplicationFacade.VOLUME :
					var v:Number = Math.max(0, Math.min(1, Number(o)));
					if(aP) aP.volume = v;
					if(vP) vP.volume = v;
					break;
				case ApplicationFacade.VOLUME_RELATIVE :
					// Todo: Update volume slider as well
					//m.volume = m.volume + Number(o);
					break;
				case ApplicationFacade.BUFFER :
					if(aP) aP.buffer = int(o);
					if(vP) vP.buffer = int(o);
					break;
				case ApplicationFacade.SET_VIDEO :
					if(vP) IVideoProxy(vP).video = o as Video;
					break;
			}
		}
	}
}