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

package cv.managers {
	
	import cv.TempoLite;
	import cv.data.PlayList;
	import cv.formats.ASX;
	import cv.formats.XSPF;
	import cv.formats.M3U;
	//import cv.formats.PLS;
	//import cv.formats.B4S;
	import cv.formats.ATOM;
	//import cv.formats.RSS;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	//--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched when the playlist is cleared, a new playlist is loaded, or a single meida is loaded.
	 *
	 * @eventType cv.TempoLite.NEW_PLAYLIST
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "newPlaylist", type = "flash.events.Event")]
	
	/**
	 * Dispatched when ever an item is removed, or updated, or the entire list is updated
	 *
	 * @eventType cv.TempoLite.REFRESH_PLAYLIST
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	[Event(name = "refreshPlaylist", type = "flash.events.Event")]
	
	//--------------------------------------
    //  Class description
    //--------------------------------------	
    /**
	 * The PlayListManager class handles the PlayList component of TempoLite. It will
	 * handle the parsing of the playlist file types. It also manages shuffling, 
	 * and loading of single media items.
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.115.0
     */
    public class PlayListManager extends EventDispatcher {
		
		private var listShuffled:PlayList;
		private var strExt:String; // File extension
		private var _autoStart:Boolean = true;
		private var _autoStartIndex:int = 0;
		private var _list:PlayList =  new PlayList();
		private var _repeat:Boolean = false;
		private var _repeatAll:Boolean = true;
		private var _shuffle:Boolean = false;
		private var strRepeat:String;
		
		public function PlayListManager() {
			updateList();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/** 
		 * Gets or sets whether media will play automatically once the playlist is loaded.
		 * 
		 * @default true
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get autoStart():Boolean { return _autoStart	}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set autoStart(b:Boolean):void {	_autoStart = b }
		
		/** 
		 * Gets or sets the index of the item that would play if autoStart is enabled.
		 * 
		 * @default 0
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get autoStartIndex():int { return _autoStartIndex }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set autoStartIndex(n:int):void { _autoStartIndex = n }
		
		/** 
		 * Gets a reference to the PlayList
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get list():PlayList { return _list }
		
		/** 
		 * Gets or sets whether repeat is enabled, or which type of repeat is enabled.
		 * Accepted values are:
		 * <ul>
		 * <li>TempoLite.REPEAT_ALL</li>
		 * <li>TempoLite.REPEAT_TRACK</li>
		 * <li>TempoLite.REPEAT_NONE</li>
		 * </ul>
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get repeat():String {
			return strRepeat;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set repeat(str:String):void {
			switch(str) {
				case TempoLite.REPEAT_ALL :
					_repeatAll = list.repeatAll = true;
					_repeat = list.repeat = false;
					strRepeat = str;
					break;
				case TempoLite.REPEAT_TRACK : 
					_repeatAll = list.repeatAll = false;
					_repeat = list.repeat = true;
					strRepeat = str;
					break;
				case TempoLite.REPEAT_NONE :
					_repeatAll = list.repeatAll = false;
					_repeat = list.repeat = false;
					strRepeat = str;
			}
		}
		
		/*public function set repeatAll(b:Boolean):void {
			_repeatAll = list.repeatAll = b;
		}
		public function get repeatAll():Boolean {
			return _repeatAll;
		}*/
		
		/** 
		 * Gets or sets whether shuffle is enabled or not.
		 *
		 * @playerversion Flash 9
		 * @langversion 3.0
		 * @category Property
		 */
		public function get shuffle():Boolean {	return _shuffle }
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.115.0
         */
		public function set shuffle(b:Boolean):void { _shuffle = b }
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		/**
		 * Adds an item to the playlist. The index at which it is added can
		 * be specified but not required.
		 * 
		 * @param oItem	An Item object
		 * 
		 * @default -1
		 * @param nIdx	The index in which ot add the item at
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
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
		
		/**
		 * Removes all items from the playlist and dispatches the TempoLite.NEW_PLAYLIST event.
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function clear():void {
			_list = new PlayList();
			//_list.index = 0;
			dispatchEvent(new Event(TempoLite.NEW_PLAYLIST));
		}
		
		/**
		 * Returns the next item in the playlist
		 * 
		 * @return The next Item object in the playlist
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
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
		
		/**
		 * Returns the previous item in the playlist
		 * 
		 * @return The previous Item object in the playlist
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
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
		
		/**
		 * Loads a playlist file to be used as a playlist
		 * 
		 * @param s The url to the playlist file
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function load(s:String):void {
			strExt = s.substr( -3).toLowerCase();
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadedHandler);
			loader.load(new URLRequest(s));
		}
		
		/**
		 * Creates a new playlist with a single item, the item passed in as a parameter.
		 * Also dispatches a TempoLite.NEW_PLAYLIST event.
		 * 
		 * @param oItem An Item object, which will be the sole item in the playlist
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function loadSingle(oItem:Object):void {
			clear();
			addItem(oItem);
			
			dispatchEvent(new Event(TempoLite.NEW_PLAYLIST));
		}
		
		/**
		 * Removes an item from the playlist. If no index is specified, it removes
		 * the last item in the playlist.
		 * 
		 * @default -1
		 * @param idx The index of the item to be removed
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function removeItem(idx:int = -1):void {
			if (idx < 0) idx = _list.length - 1; // Get last item in the list
			_list.removeAt(idx);
			dispatchEvent(new Event(TempoLite.REFRESH_PLAYLIST));
		}
		
		/**
		 * Updates the title used for an Item in the playlist. This is used
		 * in situations where the metadata has been loaded, and the correct title is updated
		 * for the playlist display. Dispatches the TempoLite.REFRESH_PLAYLIST event.
		 * 
		 * @param idx The index of the item to be updated
		 * @param strTitle The new title to be used
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function updateItemTitle(idx:uint, strTitle:String):void {
			_list[idx].title = strTitle;
			dispatchEvent(new Event(TempoLite.REFRESH_PLAYLIST));
		}
		
		/**
		 * Updates the length or duration used for an Item in the playlist. This is used
		 * in situations where the metadata has been loaded, and the correct duration is updated
		 * for the playlist display. Dispatches the TempoLite.REFRESH_PLAYLIST event.
		 * 
		 * @param idx The index of the item to be updated
		 * @param n The new length to be used
		 * 
		 * @playerversion Flash 9
		 * @langversion 3.0 
		 * @category Method
		 */
		public function updateItemLength(idx:uint, n:Number):void {
			n /= 1000;
			if(_list[idx].length != n) {
				_list[idx].length = n;
				dispatchEvent(new Event(TempoLite.REFRESH_PLAYLIST));
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
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
		private function getType(data:String):PlayList {
			if (strExt == "m3u") {
				return new M3U(data);
			} else {
				var xml:XML = new XML(data);
				switch(xml.localName().toLowerCase()) {
					case "playlist" :
						return new XSPF(xml);
						break;
					case "asx" :
						return new ASX(xml);
						break;
					case "feed" :
						return new ATOM(xml);
						break;
					/*case "WinampXML" :
						return new B4S(xml);
						break;*/
					/*case "rss" :
						var ns:String;// = xml.namespace().uri;
						//if (ns == "http://www.w3.org/2005/Atom") return new ATOM(data);
						
						//ns = xml.namespace("media").uri;
						//if (ns == "http://search.yahoo.com/mrss/") return new mRSS(data);
						
						//ns = xml.namespace("itunes").uri;
						//if (ns == "http://www.itunes.com/dtds/podcast-1.0.dtd") return new iRSS(data);
						break;*/
					/*case "smil" :
						return new SMIL(xml);
						break;*/ 
				}
			}
			
			trace2("PlayListManager::getType - Error : Unknown playlist file type; assuming M3U.");
			return new M3U(data);
		}
		
		private function loadedHandler(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			_list = getType(loader.data as String);
			_list.index = 0;
			updateList();
			
			dispatchEvent(new Event(TempoLite.NEW_PLAYLIST));
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
			dispatchEvent(new Event(TempoLite.REFRESH_PLAYLIST));
		}
		
		private function trace2(...arguements):void {
			if (TempoLite.debug) trace(arguements);
		}
	}
}