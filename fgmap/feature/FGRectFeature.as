package fgmap.feature
{
	import fgmap.*;
	import flash.display.*;
	import flash.geom.*;

	public class FGRectFeature extends FGFeature
	{
		private var mLeftTop    :FLatLng;
		private var mRightTop   :FLatLng;
		private var mRightBottom:FLatLng;
		private var mTexture:BitmapData;

		private var mBorderWidth:Number = undefined;
		private var mBorderColor:uint = 0;

		private var mFillColor:uint = 0;
		private var mFillAlpha:Number = 0;

		function FGRectFeature(lat1:Number, lng1:Number, lat2:Number, lng2:Number)
		{
			mLeftTop     = new FLatLng(lat1, lng1);
			mRightBottom = new FLatLng(lat2, lng2);
		}

		public function set borderWidth(w:Number):void {
			mBorderWidth = w;
		}

		public function set borderColor(c:uint):void {
			mBorderColor = c;
		}

		public function set fillColor(c:uint):void {
			mFillColor = c;
		}

		public function set fillAlpha(a:Number):void {
			mFillAlpha = a;
		}

		public function setThirdAnchor(lat:Number, lng:Number):void
		{
			mRightTop = new FLatLng(lat, lng);
		}

		public function set texture(b:BitmapData):void
		{
			mTexture = b;
		}

		public override function redraw(m:FGMap):void
		{
			var p1:Point = new Point();
			var p2:Point = new Point();

			var p3:Point = new Point();
			var p4:Point = new Point();

			m.calcScreenPos(mLeftTop.lat    , mLeftTop    .lng, p1, false);
			m.calcScreenPos(mRightBottom.lat, mRightBottom.lng, p2, false);

			if (mRightTop) {
				m.calcScreenPos(mRightTop.lat, mRightTop.lng, p3, false);
			} else {
				m.calcScreenPos(mLeftTop.lat, mRightBottom.lng, p3, false);
				m.calcScreenPos(mRightBottom.lat, mLeftTop.lng, p4, false);
			}

			var g:Graphics = graphics;
			g.clear();
/*
			g.lineStyle(0, 0xff0000);
			g.moveTo(p1.x, p1.y);
			g.lineTo(p2.x, p2.y);

			if (p3) {
				g.lineStyle(0, 0x00aa00);
				g.moveTo(p1.x, p1.y);
				g.lineTo(p3.x, p3.y);
			}
*/
			if (mTexture) {
				g.beginBitmapFill(mTexture, makeMatrixFromPoints(p1, p3, p4));
			}
			else {
				if (mFillAlpha > 0.01) {
					g.beginFill(mFillColor, mFillAlpha);
				}
			}
			g.lineStyle(mBorderWidth, mBorderColor);

			g.moveTo(p1.x, p1.y);
			g.lineTo(p3.x, p3.y);
			g.lineTo(p2.x, p2.y);
			g.lineTo(p4.x, p4.y);
			g.lineTo(p1.x, p1.y);
			g.endFill();

			if (mRedrawHook != null)
				mRedrawHook(this);
		}

		public function makeMatrixFromPoints(p0:Point, pR:Point, pB:Point):Matrix
		{
			var m:Matrix = new Matrix();

			FGPolygonFeature.calcTexTrans([pR, p0, pB], m, mTexture);

			return m;
		}
	}
}
