package fgmap.feature
{
	import fgmap.feature.*;
	import flash.display.*;
	import flash.geom.*;
	import fgmap.*;

	public class FGIconFeature extends FGFeature
	{
		private var mIconBitmap:Bitmap;
		private var mHotX:int, mHotY:int;

		public var hpos:Number;
		public var altpos:Number;
		public var faceIndex:int;

		static private var OrangeTrans:ColorTransform = new ColorTransform(1,0.75,0.7,1, 40, 20, 0);
		static private var DefaultTrans:ColorTransform = new ColorTransform();

		function FGIconFeature(b:Bitmap)
		{
			mHotX = 0;
			mHotY = 0;
			mIconBitmap = b;
			addChild(b);
		}

		public function set highlight(h:Boolean):void {
			this.transform.colorTransform = h ? OrangeTrans : DefaultTrans;
		}

		public function set hotX(hx:int):void {
			mHotX = 0;
			mIconBitmap.x = -hx;
		}

		public function set hotY(hy:int):void {
			mHotY = 0;
			mIconBitmap.y = -hy;
		}

		public override function redraw(m:FGMap):void
		{
			if (mRedrawHook != null)
				mRedrawHook(this);
		}

		public override function calcCenterY():int
		{
			return y;
		}

		public override function get useSorter():Boolean
		{
			return true;
		}

		public override function get independentTransform():Boolean {
			return true;
		}

		private var _tmpPt:Point = new Point();
		public function putAtLL(ll:FLatLng, m:FGMap):void
		{
			calcScreenPos(m, ll, _tmpPt);
			x = _tmpPt.x;
			y = _tmpPt.y;
		}
	}
}
