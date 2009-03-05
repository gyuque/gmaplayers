package fgmap.xmap.events
{
	import fgmap.xmap.*;
	import flash.events.*;

	public class TextureEditorEvent extends Event
	{
		public static const PANEL_OPEN:String    = "texture_panel_open";
		public static const PANEL_CLOSE:String   = "texture_panel_close";
		public static const FACE_SELECTED:String = "texture_face_selected";
		public static const TEXTURE_REMOVED:String = "texture_face_removed";
		public var panel:TexturePanel;
		public var face:int;

		function TextureEditorEvent(t:String)
		{
			super(t, true);
		}
	}
}