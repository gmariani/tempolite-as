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
 * Aggregated API for Tempo. Used with Flash IDE, JavaScriptMediator, FlashVarMediator
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */
 
package com.coursevector.tempo.view {

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.tempo.view.events.PlayerEvent;
	import com.coursevector.tempo.interfaces.IMediaProxy;
	import com.coursevector.tempo.model.PlayListProxy;
	import com.coursevector.data.PlayList;

	public class APIMediator extends Mediator implements IMediator, IEventDispatcher  {
		
		public static const NAME:String = 'APIMediator';
		private var _id:String = "1";
		private var dispatcher:EventDispatcher;
		private var plP:PlayListProxy;
		
		public function APIMediator() {
			super(NAME);
			
			dispatcher = new EventDispatcher(this);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/**
		 * Determines if the playlist starts playing as soon as a new playlist is loaded
		 */
		public function get autoStart():Boolean {
			return plP.autoStart;
		}
		/**
		 *  @private
		 */
		public function set autoStart(b:Boolean):void {
			sendNotification(ApplicationFacade.AUTO_START, b);
		}
		
		/**
		 * If autoStart is enabled, at which item do you want to start first
		 */
		public function get autoStartIndex():int {
			return plP.autoStartIndex;
		}
		/**
		 *  @private
		 */
		public function set autoStartIndex(n:int):void {
			sendNotification(ApplicationFacade.AUTO_START_INDEX, n);
		}
		
		/**
		 * Buffer for the media to preload before playing
		 */
		public function get bufferTime():int {
			return cP.buffer;
		}
		/**
		 *  @private
		 */
		public function set bufferTime(n:int):void {
			sendNotification(ApplicationFacade.BUFFER, n);
		}
		
		private function get cP():IMediaProxy {
			return ApplicationFacade.currentMediaProxy;
		}
		
		/*
		public function get checkPolicyFile():Boolean {
			return cP.buffer;
		}
		/**
		 *  @private
		 /
		public function set checkPolicyFile(b:Boolean):void {
			sendNotification(ApplicationFacade.BUFFER, n);
		}*/
		
		public function set fileURL(value:String):void {
			loadMedia(value);
		}
		
		/**
		 * Used as a unique ID when used in HTML
		 */
		public function get id():String {
			return _id;
		}
		/**
		 *  @private
		 */
		public function set id(str:String):void {
			_id = str;
		}
		
		public function get isPause():Boolean {
			return cP.isPause;
		}
		
		public function set playlistURL(value:String):void {
			loadPlayList(value);
		}
		
		public function set playerId(value:String):void {
			this.id = value;
		}
		
		/**
		 * Determines whether the playlist loops or loops on a single item
		 */
		public function get repeat():String {
			if(plP) return plP.repeat;
			return PlayerEvent.REPEAT_NONE;
		}
		/**
		 *  @private
		 */
		public function set repeat(str:String):void {
			switch(str) {
				case PlayerEvent.REPEAT_ALL:
				case PlayerEvent.REPEAT_NONE:
				case PlayerEvent.REPEAT_TRACK:
					break;
				default:
					return;
			}
			
			sendNotification(ApplicationFacade.REPEAT_PLAYLIST, str);
		}
		
		/**
		 * If the playlist is shuffled
		 */
		public function get shuffle():Boolean {
			return plP.shuffle;
		}
		/**
		 *  @private
		 */
		public function set shuffle(b:Boolean):void {
			sendNotification(ApplicationFacade.SHUFFLE_PLAYLIST, b);
		}
		
		public function set skinURL(value:String):void {
			loadSkin(value);
		}
		
		/**
		 * Volume of the media playing
		 */
		public function get volume():Number { return cP.volume }
		/**
		 *  @private
		 */
		public function set volume(n:Number):void {
			sendNotification(ApplicationFacade.VOLUME, Math.max(0, Math.min(1, n)));
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function addItem(oItem:Object, nIdx:int = -1):void {
			sendNotification(ApplicationFacade.ADD_ITEM, {item:oItem, index:nIdx});
		}
		
		public function clearItems():void {
			sendNotification(ApplicationFacade.CLEAR_PLAYLIST);
		}
		
		public function getCurrentPercent():uint {
			return cP.currentPercent;
		}
		
		public function getList():PlayList {
			return plP.list;
		}
		
		public function getLoadCurrent():Number {
			return cP.loadCurrent;
		}
		
		public function getLoadTotal():Number {
			return cP.loadTotal;
		}
		
		public function getMetaData():Object {
			return cP.metaData;
		}
		
		public function getTimeCurrent():String {
			var n:Number = cP.timeCurrent != 0 ? cP.timeCurrent / 1000 : 0;
			return convertTime(n);
		}
		
		public function getTimeLeft():String {
			var n:Number = cP.timeLeft != 0 ? cP.timeLeft / 1000 : 0;
			return "-" + convertTime(n);
		}
		
		public function getTimeTotal():String {
			var n:Number = cP.timeTotal != 0 ? cP.timeTotal / 1000 : 0;
			return convertTime(n);
		}
		
		public function loadMedia(oItem:Object, autoStart:Boolean = true):void {
			this.autoStart = autoStart;
			plP.loadSingle(oItem);
		}
		
		public function unloadMedia():void {
			sendNotification(ApplicationFacade.UNLOAD);
		}
		
		public function loadPlayList(str:String = "playlists/Tempo.m3u"):void {
			sendNotification(ApplicationFacade.LOAD_PLAYLIST, str);
		}
		
		public function loadSkin(str:String = "DefaultSkin.swf"):void {
			sendNotification(ApplicationFacade.NEW_SKIN, str);
		}
		
		public function next():void {
			sendNotification(ApplicationFacade.NEXT);
		}
		
		public function pause(b:Boolean = true):void {
			sendNotification(ApplicationFacade.PAUSE, b);
		}
		
		public function play(idx:int = -1):void {
			if (idx >= 0) {
				plP.list.index = idx;
				sendNotification(ApplicationFacade.LOAD, plP.list.getCurrent());
			} else {
				sendNotification(ApplicationFacade.PLAY);
			}
		}
		
		public function previous():void {
			sendNotification(ApplicationFacade.PREVIOUS);
		}
		
		// Playlist item object
		public function removeItem(idx:int = -1):void {
			sendNotification(ApplicationFacade.REMOVE_ITEM, idx);
		}
		
		public function seek(n:Number):void {
			sendNotification(ApplicationFacade.SEEK_TIME, n);
		}
		
		// 0 - 1
		public function seekPercent(n:Number):void {
			sendNotification(ApplicationFacade.SEEK, n);
		}
		
		public function seekRelative(n:Number):void {
			sendNotification(ApplicationFacade.SEEK_RELATIVE, n);
		}
		
		public function setMute(b:Boolean):void {
			sendNotification(ApplicationFacade.MUTE, b);
		}
		
		public function setVideoScale(str:String = PlayerEvent.MAINTAIN_ASPECT_RATIO):void {
			switch(str) {
				case PlayerEvent.MAINTAIN_ASPECT_RATIO :
				case PlayerEvent.EXACT_FIT :
				case PlayerEvent.NO_SCALE :
					break;
				default :
					throw("Invalid scale mode. Valid values: " + PlayerEvent.MAINTAIN_ASPECT_RATIO + ", " + PlayerEvent.EXACT_FIT + ", " + PlayerEvent.NO_SCALE);
					return;
			}
			sendNotification(ApplicationFacade.NEW_SCALE_MODE, str);
		}
		
		public function stop():void {
			sendNotification(ApplicationFacade.STOP);
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			plP = facade.retrieveProxy(PlayListProxy.NAME) as PlayListProxy;
		}
		
		// Doesn't handle ApplicationFacade.LOAD_COMPLETE becuase that is 
		// only sent with VideoProxy
		override public function listNotificationInterests():Array {
			return [
					ApplicationFacade.PLAY_START,
					ApplicationFacade.PLAY_PROGRESS,
					ApplicationFacade.PLAY_COMPLETE,
					ApplicationFacade.NEXT,
					ApplicationFacade.PREVIOUS,
					ApplicationFacade.LOAD_START,
					ApplicationFacade.LOAD_PROGRESS,
					ApplicationFacade.AUDIO_METADATA,
					ApplicationFacade.VIDEO_METADATA,
					ApplicationFacade.REFRESH_PLAYLIST,
					ApplicationFacade.NEW_PLAYLIST
				   ];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName())	{
				case ApplicationFacade.AUDIO_METADATA :
					dispatchEvent(new Event(ApplicationFacade.AUDIO_METADATA));
					break;
				case ApplicationFacade.VIDEO_METADATA :
					dispatchEvent(new Event(ApplicationFacade.VIDEO_METADATA));
					break;
				case ApplicationFacade.PLAY_START :
					dispatchEvent(new Event(ApplicationFacade.PLAY_START));
					break;
				case ApplicationFacade.PLAY_PROGRESS :
					dispatchEvent(new Event(ApplicationFacade.PLAY_PROGRESS));
					break;
				case ApplicationFacade.PLAY_COMPLETE :
					dispatchEvent(new Event(ApplicationFacade.PLAY_COMPLETE));
					break;
				case ApplicationFacade.NEXT :
					dispatchEvent(new Event(ApplicationFacade.NEXT));
					break;
				case ApplicationFacade.PREVIOUS :
					dispatchEvent(new Event(ApplicationFacade.PREVIOUS));
					break;
				case ApplicationFacade.LOAD_START :
					dispatchEvent(new Event(ApplicationFacade.LOAD_START));
					break;
				case ApplicationFacade.LOAD_PROGRESS :
					dispatchEvent(new Event(ApplicationFacade.LOAD_PROGRESS));
					break;
				case ApplicationFacade.REFRESH_PLAYLIST :
					dispatchEvent(new Event(ApplicationFacade.REFRESH_PLAYLIST));
					break;
				case ApplicationFacade.NEW_PLAYLIST :
					dispatchEvent(new Event(ApplicationFacade.NEW_PLAYLIST));
					break;
			}
		}
		
		//--------------------------------------
		//  Event Dispatcher
		//--------------------------------------
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}

		public function dispatchEvent(evt:Event):Boolean{
			return dispatcher.dispatchEvent(evt);
		}

		public function hasEventListener(type:String):Boolean{
			return dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function convertTime(n:Number):String {
			var m:String = int(n / 60).toString();
			var s:String = int(int(n) % 60).toString();
			if (int(s) < 10) s = "0" + s;
			return m + ":" + s;
		}
	}
}