package {
	
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;

	public class WinampCellRenderer extends CellRenderer implements ICellRenderer {
		
		public function WinampCellRenderer() {
			setStyle("upSkin", Winamp_CellRenderer_upSkin);
			setStyle("overSkin", Winamp_CellRenderer_upSkin);
			setStyle("disabledSkin", Winamp_CellRenderer_upSkin);
			
			setStyle("downSkin", Winamp_CellRenderer_selectedUpSkin);
			setStyle("selectedDisabledSkin", Winamp_CellRenderer_selectedUpSkin);
			setStyle("selectedUpSkin", Winamp_CellRenderer_selectedUpSkin);
			setStyle("selectedDownSkin", Winamp_CellRenderer_selectedUpSkin);
			setStyle("selectedOverSkin", Winamp_CellRenderer_selectedUpSkin);
		}
		
		override public function set data(d:Object):void {
			_data = d;
			label = getLabel();
		}
		
		override public function set listData(value:ListData):void {
			_listData = value;
			label = getLabel();
			//setStyle("icon", _listData.icon);
		}
		
		private function getLabel():String {
			// ##. #Artist# - #Title# - 00:00
			var str:String = "";
			if(_listData) {
				if(_listData.index >= 0) {
					str += (_listData.index + 1) + ". ";
				}
			}
			str += _data.label;
			if(_data.data) {
				if(_data.data.length >= -1) {
					str +=  " - " + convertTime(_data.data.length);
				}
			}
			return str;
		}
		
		private function convertTime(n:Number):String {
			if(n == -1) return "00:00";
			var m:String = int(n / 60).toString();
			var s:String = int(int(n) % 60).toString();
			if (s < 10) s = "0" + s;
			return m + ":" + s;
		}
	}
}