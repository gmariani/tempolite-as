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
	public interface IMediaProxy {
		function get buffer():int;
		function set buffer(n:int):void;
		function get currentPercent():uint;
		function get isPause():Boolean;
		function get loadCurrent():Number;
		function get loadTotal():Number;
		function get volume():Number;
		function set volume(n:Number):void;
		function get metaData():Object;
		function get timeCurrent():Number;
		function get timeLeft():Number;
		function get timeTotal():Number;
		function isValid(str:String):Boolean;
		function load(s:String):void;
		function mute(b:Boolean = true):void;
		function pause(b:Boolean = true):void;
		function play(pos:int = 0):void;
		function seek(n:Number):void;
		function seekPercent(n:Number):void;
		function stop(pos:int = 0):void;
		function unLoad():void;
	}
}