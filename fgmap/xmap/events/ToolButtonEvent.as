package fgmap.xmap.events
{
	import fgmap.xmap.*;
	import flash.events.*;

	public class ToolButtonEvent extends Event
	{
		public static const CLICK:String = "toolbutton_click";

		function ToolButtonEvent(t:String = CLICK)
		{
			super(t, true);
		}
	}
}
