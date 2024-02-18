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

package com.coursevector.tempo.interfaces {
	
	import flash.media.Video;

	public interface IVideoProxy {
		function get autoScale():Boolean;
		function set autoScale(b:Boolean):void;
		function get video():Video;
		function set video(v:Video):void;
	}
}