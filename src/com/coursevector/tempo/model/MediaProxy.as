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
 * A single class to control both the Video and Audio proxy
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

/*
	mimetypes = new Object();
	mimetypes.mp3 = "mp3";
	mimetypes["audio/mpeg"] = "mp3";
	mimetypes.flv = "flv";
	mimetypes["video/x-flv"] = "flv";
	mimetypes.jpeg = "jpg";
	mimetypes.jpg = "jpg";
	mimetypes["image/jpeg"] = "jpg";
	mimetypes.png = "png";
	mimetypes["image/png"] = "png";
	mimetypes.gif = "gif";
	mimetypes["image/gif"] = "gif";
	mimetypes.rtmp = "rtmp";
	mimetypes.swf = "swf";
	mimetypes["application/x-shockwave-flash"] = "swf";
	mimetypes.rtmp = "rtmp";
	mimetypes["application/x-fcs"] = "rtmp";
	mimetypes["audio/x-m4a"] = "m4a";
	mimetypes["video/x-m4v"] = "m4v";
	mimetypes["video/H264"] = "mp4";
	mimetypes["video/3gpp"] = "3gp";
	mimetypes["video/x-3gpp2"] = "3g2";
	mimetypes["audio/x-3gpp2"] = "3g2";
*/

package com.coursevector.tempo.model {
	
    import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import com.coursevector.tempo.interfaces.IMediaProxy;
	
	public class MediaProxy extends Proxy implements IProxy {
		
		public static const NAME:String = 'MediaProxy';
		private var _buffer:int = 1;
		private var _volume:Number = 0.5;
		private var aP:IMediaProxy;
		private var cP:IMediaProxy; // Current Proxy
		private var vP:IMediaProxy;
		
		public function MediaProxy() {
            super(NAME);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function set buffer(n:int):void {
			_buffer = n;
			if(aP) aP.buffer = _buffer;
			if(vP) vP.buffer = _buffer;
		}
		public function get buffer():int { return _buffer }
		
		public function get currentPercent():uint { return cP ? cP.currentPercent : 0 }
		
		public function get isPause():Boolean { return cP ? cP.isPause : false }
		
		public function get loadCurrent():Number { return cP ? cP.loadCurrent : 0 }
		
		public function get loadTotal():Number { return cP ? cP.loadTotal : 0 }
		
		public function get metaData():Object { return cP ? cP.metaData : null }
		
		public function get timeCurrent():Number { return cP ? cP.timeCurrent : 0 }
		
		public function get timeLeft():Number { return cP ? cP.timeLeft : 0 }
		
		public function get timeTotal():Number { return cP ? cP.timeTotal : 0 }
		
		public function set volume(n:Number):void {
			_volume = Math.max(0, Math.min(1, n));
			if(aP) aP.volume = _volume;
			if(vP) vP.volume = _volume;
		}
		public function get volume():Number { return _volume }
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function load(s:String):void {
			var strExt:String = s.substr( -3).toLowerCase();
			
			if(aP) aP.unLoad();
			if(vP) vP.unLoad();
			
			if (aP && aP.isValid(strExt)) {
				cP = aP;
				aP.load(s);
			} else if (vP.isValid(strExt) && vP) {
				cP = vP;
				vP.load(s);
			}
		}
		
		public function unload():void {
			if(aP) aP.unLoad();
			if(vP) vP.unLoad();
		}
		
		public function stop():void { if (cP) cP.stop() }
		
		public function play():void { if (cP) cP.play() }
		
		public function pause(b:Boolean):void { if (cP) cP.pause(b) }
		
		public function seekPercent(n:Number):void { if(cP) cP.seekPercent(n) }
		
		public function seek(n:Number):void { if(cP) cP.seek(n) }
		
		public function mute(b:Boolean):void {
			if(aP) aP.mute(b);
			if(vP) vP.mute(b);
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			aP = facade.retrieveProxy("AudioProxy") as IMediaProxy;
			vP = facade.retrieveProxy("VideoProxy") as IMediaProxy;
			volume = _volume;
			buffer = _buffer;
		}
	}
}