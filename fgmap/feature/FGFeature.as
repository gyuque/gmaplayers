package fgmap.feature
{
	import flash.display.*;
	import fgmap.*;
	import flash.geom.*;
	public class FGFeature extends Sprite
	{
		private var mOwner:FGMapLayer;
		protected var mClientDatas:Object = null;
		protected var mRedrawHook:Function = null;

		public function redraw(m:FGMap):void
		{
		}

		public function calcScreenPos(m:FGMap, ll:FLatLng, pt:Point):void
		{
			m.calcScreenPos(ll.lat, ll.lng, pt, true);
			pt.y += owner.altOffsetY;
		}

		public function set redrawHook(f:Function):void
		{
			mRedrawHook = f;
		}


		public function get clientData():Object {
			if (!mClientDatas)
				mClientDatas = {};

			return mClientDatas;
		}

		public function set owner(lyr:FGMapLayer):void 
		{
			mOwner = lyr;
		}

		public function get owner():FGMapLayer
		{
			return mOwner;
		}

		public function get independentTransform():Boolean
		{
			return false;
		}

		public function get useSorter():Boolean
		{
			return false;
		}

		public function calcCenterY():int
		{
			return 0;
		}
	}
}
