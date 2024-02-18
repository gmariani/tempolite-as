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
* Initializes the Model and Views and their sub components
* Initializes the StageMediator and passes the stage reference
* Initializes the proxies
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.tempo.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.tempo.view.SkinMediator;
	import com.coursevector.tempo.view.JavaScriptMediator;
	import com.coursevector.tempo.view.FlashVarMediator;
	import com.coursevector.tempo.view.APIMediator;
	//import com.coursevector.tempo.view.KeyBoardMediator;
	//import com.coursevector.tempo.view.MenuMediator;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.model.AudioProxy;
	import com.coursevector.tempo.model.VideoProxy;
	import com.coursevector.tempo.model.PlayListProxy;
	
	import flash.display.DisplayObjectContainer;
	
	public class StartupCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			
			//--------------------------------------
			//  View
			//--------------------------------------
			
			var stage:DisplayObjectContainer = note.getBody() as DisplayObjectContainer;
			
			// Skin Support
			var sM:SkinMediator = new SkinMediator(stage);
			facade.registerMediator(sM);
			
			// Global API
			facade.registerMediator(new APIMediator());
			
			// JavaScript Support
			facade.registerMediator(new JavaScriptMediator(stage));
			
			// FlashVar Support
			facade.registerMediator(new FlashVarMediator(sM.holder));
			
			// Context Menu
			//facade.registerMediator(new MenuMediator(sM.holder));
			
			// Keyboard Menu
			//facade.registerMediator(new KeyBoardMediator(stage));
			
			//--------------------------------------
			//  Model
			//--------------------------------------
			
			// Audio Support
			facade.registerProxy(new AudioProxy());
			
			// Video Support
			var vP:VideoProxy = new VideoProxy();
			facade.registerProxy(vP);
			
			// Set current to video
			ApplicationFacade.currentMediaProxy = vP;
			
			// PlayList Support
			facade.registerProxy(new PlayListProxy());
			
			sendNotification(ApplicationFacade.INITIALIZED);
		}
	}
}