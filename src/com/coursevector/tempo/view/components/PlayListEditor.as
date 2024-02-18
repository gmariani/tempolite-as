package com.coursevector.tempo.view.components {
	
	import fl.events.ListEvent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import com.coursevector.data.PlayList;
	import com.coursevector.tempo.ApplicationFacade;
	
	public class PlayListEditor extends Sprite {
		
		private var _pl:PlayList;
		private var _list:DisplayObject; // List
		
		public function PlayListEditor(mc:DisplayObjectContainer):void {
			init(mc);
		}
		
		public function set list(pl:PlayList):void {
			if(pl) {
				if (_pl) _pl.removeEventListener(PlayList.CHANGE, playlistHandler);
				_pl = pl;
				_pl.addEventListener(PlayList.CHANGE, playlistHandler);
				
				refreshPlayList();
				dispatchEvent(new Event(ApplicationFacade.CHANGE));
			}
		}
		public function get list():PlayList { return _pl }
		
		public function get selectedIndex():uint {
			return _list ? _list.selectedIndex : _pl.index;
		}
		
		public function refreshPlayList():void {
			if (_list && _pl) {
				_list.dataProvider = _pl.toDataProvider();
				_list.selectedIndex = _pl.index;
			}
		}
		
		private function init(mc:DisplayObjectContainer):void {
			var child:DisplayObject = mc.getChildByName('song_list');
			if (child) {
				_list = child;
				_list.addEventListener(ListEvent.ITEM_CLICK, listHandler);
				refreshPlayList();
			}
		}
		
		private function listHandler(e:ListEvent):void {
			_pl.index = uint(e.rowIndex);
			dispatchEvent(new Event(ApplicationFacade.CHANGE));
		}
		
		private function playlistHandler(e:Event):void {
			if (_list) {
				_list.selectedIndex = _pl.index;
				_list.scrollToIndex(_pl.index);
			}
		}
	}
}