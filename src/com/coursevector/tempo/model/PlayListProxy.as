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
 * Manages the selected playlist
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

package com.coursevector.tempo.model {
	
    import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import com.coursevector.tempo.ApplicationFacade;
	import com.coursevector.data.PlayList;
	import com.coursevector.formats.ASX;
	import com.coursevector.formats.XSPF;
	import com.coursevector.formats.M3U;
	import com.coursevector.formats.PLS;
	import com.coursevector.formats.B4S;
	//import com.coursevector.formats.RSS;
	import com.coursevector.tempo.view.events.PlayerEvent;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

    public class PlayListProxy extends Proxy implements IProxy {
        public static const NAME:String = 'PlayListProxy';
		
		private var listShuffled:PlayList;
		private var strExt:String; // File extension
		private var _autoStart:Boolean = true;
		private var _autoStartIndex:int = 0;
		private var _list:PlayList =  new PlayList();
		private var _repeat:Boolean = false;
		private var _repeatAll:Boolean = true;
		private var _shuffle:Boolean = false;
		private var strRepeat:String;
		
		public function PlayListProxy() {
            super(NAME);
        }
		
		public function set autoStart(b:Boolean):void {	_autoStart = b }
		public function get autoStart():Boolean { return _autoStart	}
		
		public function set autoStartIndex(n:int):void { _autoStartIndex = n }
		public function get autoStartIndex():int { return _autoStartIndex }
		
		// Returns a reference to the PlayList
		public function get list():PlayList { return _list }
		public function set repeat(str:String):void {
			switch(str) {
				case PlayerEvent.REPEAT_ALL :
					_repeatAll = list.repeatAll = true;
					_repeat = list.repeat = false;
					strRepeat = str;
					break;
				case PlayerEvent.REPEAT_TRACK : 
					_repeatAll = list.repeatAll = false;
					_repeat = list.repeat = true;
					strRepeat = str;
					break;
				case PlayerEvent.REPEAT_NONE :
					_repeatAll = list.repeatAll = false;
					_repeat = list.repeat = false;
					strRepeat = str;
			}
		}
		public function get repeat():String {
			return strRepeat;
		}
		
		/*public function set repeatAll(b:Boolean):void {
			_repeatAll = list.repeatAll = b;
		}
		public function get repeatAll():Boolean {
			return _repeatAll;
		}*/
		
		public function set shuffle(b:Boolean):void { _shuffle = b }
		public function get shuffle():Boolean {	return _shuffle }
		
		//public function addItem(strURL:String, strTitle:String = "", nLength:int = -1, nIdx:int = undefined):void {
		public function addItem(oItem:Object, nIdx:int = -1):void {
			if (!oItem.title) oItem.title = "";
			if (!oItem.length) oItem.length = -1;
			
			if (nIdx >= 0) {
				var tempPl:Array = _list.splice(nIdx);
				_list[nIdx] = oItem;
				_list = _list.concat(tempPl) as PlayList;
			} else {
				_list.push(oItem);
			}
			updateList();
		}
		
		// Remove all items
		public function clear():void {
			_list = new PlayList();
			_list.index = 0;
			sendNotification(ApplicationFacade.NEW_PLAYLIST, {autoStart:_autoStart, autoStartIndex:_autoStartIndex});
		}
		
		public function getNext():Object {
			var o:Object;
			if (!_shuffle || _list.repeat || _list.repeatAll) {
				o = _list.getNext();
				listShuffled.index = _list.index;
				return o;
			} else {
				o = listShuffled.getNext();
				_list.index = o.index;
				return _list.getCurrent();
			}
		}
		
		public function getPrevious():Object {
			var o:Object;
			if(!_shuffle || _list.repeat || _list.repeatAll) {
				o = _list.getPrevious();
				listShuffled.index = _list.index;
				return o;
			} else {
				o = listShuffled.getPrevious();
				_list.index = o.index;
				return _list.getCurrent();
			}
		}
		
		public function load(s:String):void {
			strExt = s.substr( -3).toLowerCase();
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadedHandler);
			loader.load(new URLRequest(s));
		}
		
		public function loadSingle(oItem:Object):void {
			clear();
			addItem(oItem);
			updateList();
			
			sendNotification(ApplicationFacade.NEW_PLAYLIST, {autoStart:_autoStart, autoStartIndex:_autoStartIndex});
		}
		
		public function removeItem(idx:int = -1):void {
			if (idx < 0) idx = _list.length - 1; // Get last item in the list
			_list.removeAt(idx);
			sendNotification(ApplicationFacade.REFRESH_PLAYLIST);
		}
		
		public function updateItemTitle(idx:uint, strTitle:String):void {
			_list[idx].title = strTitle;
			sendNotification(ApplicationFacade.REFRESH_PLAYLIST);
		}
		
		public function updateItemLength(idx:uint, n:Number):void {
			n /= 1000;
			if(_list[idx].length != n) {
				_list[idx].length = n;
				sendNotification(ApplicationFacade.REFRESH_PLAYLIST);
			}
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			updateList();
		}
		
		// Check for files without a title from metadata
		// Extracts the file name from the url if there is no given title
		private function checkTitle(item:Object, idx:int, arr:Array):void {
			if (item.title == "") {
				var arrURL:Array = item.url.indexOf("\\") != -1 ? item.url.split("\\") : item.url.split("/");
				item.title = arrURL[arrURL.length - 1];
			}
			
			listShuffled.push(item);
		}
		
		// Determines what kind of playlist is loaded and returns in PlayList format
		private function getType(data:*):PlayList {
			switch(strExt) {
				case "asx" :
					return new ASX(data);
					break;
				case "spf" :
					return new XSPF(data);
					break;
				case "m3u" :
					return new M3U(data);
					break;
				case "pls" :
					return new PLS(data);
					break;
				case "b4s" :
					return new B4S(data);
					break;
				default :
					trace("PlayListProxy::getType - Error : Unknown playlist file type; assuming M3U.");
					return new M3U(data);
			}
		}
		
		private function loadedHandler(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			_list = getType(loader.data);
			_list.index = 0;
			updateList();
			
			sendNotification(ApplicationFacade.NEW_PLAYLIST, {autoStart:_autoStart, autoStartIndex:_autoStartIndex});
		}
		
		private function setIndex(item:Object, idx:int, arr:Array):void {
			item.index = idx;
		}
		
		private function shuffleList(arr:PlayList):PlayList {
			var temp:PlayList = new PlayList();
			var idx:int;
			var l:int = arr.length;
			while (l > 0) {
				idx = int(Math.random() * l);
				temp.push(arr[idx]);
				arr.splice(idx, 1);
				l = arr.length;
			}
			return temp;
		}
		
		private function updateList():void {
			listShuffled = new PlayList();
			_list.forEach(checkTitle);
			
			listShuffled.forEach(setIndex);
			listShuffled = shuffleList(listShuffled);
			listShuffled.index = _list.index;
			
			_list.repeat = _repeat;
			_list.repeatAll = _repeatAll;
			listShuffled.repeat = _repeat;
			listShuffled.repeatAll = _repeatAll;
			sendNotification(ApplicationFacade.REFRESH_PLAYLIST);
		}
	}
}