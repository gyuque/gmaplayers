package fgmap.xmap.events
{
	import fgmap.xmap.*;
	import flash.events.*;

	public class IvyEvent extends Event
	{
		public static const IVY_HOVER:String       = "ivy_hover";
		public static const IVY_DRAG_CANCEL:String = "ivy_dcancel";
		public static const IVY_BEFORE_DRAG_FINISH:String = "ivy_before_drag_finish";

		private var mDropped:Boolean = false;

		function IvyEvent(t:String)
		{
			super(t, false);
		}

		public function setDrop():void {
			mDropped = true;
		}

		public function get dropped():Boolean {
			return mDropped;
		}
	}
}
