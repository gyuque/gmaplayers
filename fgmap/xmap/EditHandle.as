package fgmap.xmap
{
	import fgmap.*;
	import fgmap.feature.*;
	import flash.display.*;

	public class EditHandle extends FGIconFeature
	{
		[Embed(source="./hbox.png")]
		private static const HandleIconClass:Class;

		[Embed(source="./fhandle.gif")]
		private static const FoldHandleIconClass:Class;

		private var mHitPanel:Sprite = new Sprite();
		public var cwNext:EditHandle;
		public var ccwPrev:EditHandle;
		public var vIndex:int;
		public var unfoldOK:Boolean = false;

		function EditHandle(fold:Boolean = false)
		{
			super(new (fold ? FoldHandleIconClass : HandleIconClass)());

			mHitPanel.graphics.beginFill(0);
			mHitPanel.graphics.drawCircle(0, 0, 100);
			addChild(mHitPanel);
			mHitPanel.visible = false;
		}

		public function expandHitArea(b:Boolean):void
		{
			hitArea = b ? mHitPanel : null;
		}
	}
}