package fgmap
{
	import flash.display.*;
	import fgmap.feature.*;

	public class LayerPolygonRenderer extends Sprite
	{
		function LayerPolygonRenderer()
		{
		}

		public function startSort():void
		{
			var len:int = numChildren;
			if (len < 2) return;

			var i:int;
			var list:Array = new Array(len);
			for (i = 0;i < len;i++) {
				var c:SortContainer = new SortContainer();
				c.obj = FGFeature(getChildAt(i));
				c.key = c.obj.calcCenterY();
				list[i] = c;
			}

			list.sortOn('key');
			for(i = 0;i < len;i++)
				removeChildAt(0);

			for(i = 0;i < len;i++)
				addChild(DisplayObject(list[i].obj));
		}
	}
}

class SortContainer
{
	import fgmap.feature.FGFeature;
	public var obj:FGFeature;
	public var key:int;
}