package {
    
	import fl.controls.listClasses.CellRenderer;
    import flash.text.TextFormat;
	
    public class TabletCellRenderer extends CellRenderer {
        public function TabletCellRenderer() {
            var format:TextFormat = new TextFormat("Verdana", 30);
            setStyle("textFormat", format);
        }
    }
}