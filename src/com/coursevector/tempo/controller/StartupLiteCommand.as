/**
* 
* Initializes the Model and Views and their sub components.
* 
* MODIFIED FOR TempoLite
* 
* @author Default
* @version 0.1
*/

package com.coursevector.tempo.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.model.AudioProxy;
	import com.coursevector.tempo.model.VideoProxy;
	import com.coursevector.tempo.model.PlayListProxy;

	public class StartupLiteCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			facade.registerProxy(new AudioProxy());
			var vP:VideoProxy = new VideoProxy();
			facade.registerProxy(vP);
			facade.registerProxy(new PlayListProxy());
			ApplicationFacade.currentMediaProxy = vP;
			sendNotification(ApplicationFacade.INITIALIZED);
		}
	}
}