package fgmap.xmap.events
{
	import fgmap.xmap.*;
	import flash.events.*;

	public class PolygonEditorEvent extends Event
	{
		public static const HANDLE_STEP:String = "handle_step";
		public static const VERTEX_CREATED:String = "vertex_created";
		public var nVertices:int;

		function PolygonEditorEvent(t:String)
		{
			super(t, true);
		}
	}
}