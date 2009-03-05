package fgmap.xmap.events
{
	import fgmap.xmap.*;
	import flash.events.*;

	public class HeightEditorEvent extends Event
	{
		public static const PANEL_OPEN:String = "height_panel_open";
		public static const HEIGHT_CHANGE:String = "height_change";
		public var panel:HeightPanel;
		public var altitude:Number;

		function HeightEditorEvent(t:String)
		{
			super(t, true);
		}
	}
}
