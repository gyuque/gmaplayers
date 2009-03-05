package fgmap.xmap.events
{
	import fgmap.xmap.*;
	import flash.events.*;

	public class ToggleEvent extends Event
	{
		public static const TOGGLED:String = "toggled";
		public var btn:ToggleButton;

		function ToggleEvent()
		{
			super(TOGGLED, true);
		}
	}
}