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
 * Flashvar API, sends any commands to APIMediator
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

/*
// General
limitPlayTime:Number - Seconds
startupLogo:String - URL to logo to show when loading

onLoad:String
onTrackLoad:String
onTrackPlay:String
onTrackFinish:String
enablejs (true,false): Set this to true to enable javascript interaction. This'll only work online! Javascript interaction includes playback control, asynchroneous loading of media files and return of track information. More info at this demo page.
config (url): If you have lots of flashvars and you don't want the list to mess up your HTML pages, you can also aggregate your flashvars in a single XML file like this one.
recommendations (url): Set this to an XML with items you want to recommend. The thumbs will show up when the current movie stops playing, just like YouTube. Here's an example setup and example XML.

// Audio
defaultImage:String (AUDIO) For default cover art

// Video
mediaScale:String - (VIDEO) True, False, Fit, None
logo:String - (VIDEO) Set this to an image that can be put as a watermark logo in the top right corner of the display.

// Initial Item (basically playlist object settings)
file (url): Sets the location of the file to play. The player can play a single MP3, FLV, SWF, JPG, GIF, PNG, H264 file or a playlist. The rotator only plays playlists.
image (url): If you play a sound or movie, set this to the url of a preview image. When using a playlist, you can set an image for every entry.
captions (url): Only for the player. Assigns closed captions. Captions should be in TimedText format (example). When using a playlist, you can assign captions for every entry.
type (mp3,flv,rtmp,jpg,png,gif,swf): The player determines the type of file to play based upon the last three characters of the file flashvar. This doesn't work with database id's or mod_rewrite, so you can set this flashvar to the correct filetype. By default, the player assumes a playlist is loaded.

// Playlist
thumbsinplaylist (true,false): If you have preview images in your playlist, set this to true to show them.

// Not Implemented yet
if (fv['onLoad']) // set skin
if (fv['onTrackLoad']) // set skin
if (fv['onTrackPlay']) // set skin
if (fv['onTrackFinish']) // set skin
if (fv['enablejs']) // set skin
if (fv['config']) // set skin
if (fv['recommendations']) // set skin
if (fv['limitPlayTime']) // set skin
if (fv['startupLogo']) // set skin

// Audio
if (fv['defaultImage']) // set skin

// Image
if (fv['rotatetime']) // set skin
if (fv['transition']) // set skin

// Video
if (fv['mediaScale']) // set skin
if (fv['logo']) // set skin

// Playlist
if (fv['autoscroll']) // set skin
if (fv['thumbsinplaylist']) // set skin
*/

package com.coursevector.tempo.view {
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.view.APIMediator;
	
	import flash.display.LoaderInfo;
	
	public class FlashVarMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'FlashVarMediator';
		
		public function FlashVarMediator(viewComponent:Object) {
            super(NAME, viewComponent);
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.INITIALIZED];
		}
		
		override public function handleNotification(note:INotification):void {
			init();
		}
		
		private function init():void {
			var fv:Object = LoaderInfo(viewComponent.root.loaderInfo).parameters;
			var api:APIMediator = facade.retrieveMediator(APIMediator.NAME) as APIMediator;
			
			for (var key:String in fv) {
				if (api.hasOwnProperty(key)) {
					if(!isEmpty(fv[key])) {
						api[key] = fv[key];
					}
				}
			}
			
			if (!fv['playlistURL']) api.loadPlayList();
			if (!fv['skinURL']) api.loadSkin();
		}
		
		private function isEmpty(p_string:String):Boolean {
			if (!p_string) return true;
			return !p_string.length;
		}
	}
}