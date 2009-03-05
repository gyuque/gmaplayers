package fgmap
{
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	import fgmap.trans.*;
	import com.google.maps.Map;
	import com.google.maps.LatLng;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMoveEvent;
	import com.google.maps.MapZoomEvent;

	public class FGMap extends Sprite
	{
		public static const DEGTORAD:Number = Math.PI/180.0;

		private var mMapContainer:Sprite = new Sprite();
		private var mMapTrans:M44      = new M44();
		private var mMapTrans2D:Matrix = new Matrix();
		private var mZYFactor:Number = 0;
		private var mAltScale:Number;

		private var mGMap:Map = new Map();

		private var mRotationX:Number = 0;
		private var mRotationZ:Number = 0;

		private var mScreenWidth :int;
		private var mScreenHeight:int;

		private var mAutoUpdateTransform:Boolean = true;

		private var mLayerStack:Array;
		private var mLayerAltStack:Array;


		function FGMap(apikey:String)
		{
			mAltScale = 10.0;

			mLayerAltStack = [-1];
			mGMap.key = apikey;

			mMapContainer.addChild(mGMap);
			addChild(mMapContainer);
		}

		public function get gmap():Map {
			return mGMap;
		}

		public function get mapWidth():Number {
			return mScreenWidth;
		}

		public function get mapHeight():Number {
			return mScreenHeight;
		}

		public function setSize(sz:Point):void {
			mScreenWidth  = sz.x;
			mScreenHeight = sz.y;
			mGMap.setSize(sz);
			mGMap.x = -int(mScreenWidth/2);
			mGMap.y = -int(mScreenHeight/2);

			mGMap.addEventListener(MapMoveEvent.MOVE_STEP,    onGMapMoveStep);
			mGMap.addEventListener(MapMoveEvent.MOVE_END    , onGMapMove);
			mGMap.addEventListener(MapZoomEvent.ZOOM_CHANGED, onGMapZoom);

			buildMatrix();
			updateAltScale();
			updateVisuals();
		}

		public function updateVisuals():void
		{
			var list:Array = mLayerStack;
			if (!list)
				return;

			var len:int    = list.length;
			for (var i:int = 0;i < len;i++) {
				var lyr:FGMapLayer = list[i] as FGMapLayer;
				lyr.updateVisuals();
			}
		}

		// gmap events
		private function onGMapMoveStep(e:MapMoveEvent):void
		{
			updateAltScale();
			updateLayerFeatures();
		}

		private function onGMapMove(e:MapMoveEvent):void
		{
			updateAltScale();
			updateLayerFeatures();
		}

		private function onGMapZoom(e:MapZoomEvent):void
		{
			updateAltScale();
			buildMatrix();
			updateLayerFeatures();
		}

		// altitude <--> pixels
		private function updateAltScale():void
		{
		//	var ct:LatLng = gmap.getCenter();
		//	mAltScale = 1.0 / (Math.cos(ct.lat() * DEGTORAD) * 40074000);
			mAltScale = pixPerMeter;
		}

		public function get pixPerMeter():Number
		{
			var ct:LatLng = gmap.getCenter();
			return 1.0 / (Math.cos(ct.lat() * DEGTORAD) * 40074000) * GMapCalc.calcMapSize(gmap.getZoom());
		}

		public function updateLayerFeatures():void
		{
			var list:Array = mLayerStack;
			if (!list)
				return;

			var len:int    = list.length;
			for (var i:int = 0;i < len;i++) {
				var lyr:FGMapLayer = list[i] as FGMapLayer;
				if (lyr.visible)
					lyr.redrawFeatures();
			}
		}

		public function bringupLayer(n:int = 1):void
		{
			mLayerAltStack[mLayerAltStack.length - 1] += n;
		}

		public function pushLalyer(lyr:FGMapLayer):FGMapLayer
		{
			if (!mLayerStack) {
				mLayerStack = [];
			}

			mLayerAltStack.push( mLayerAltStack[mLayerAltStack.length - 1] + 1);

			lyr.ownerMap = this;
			mLayerStack.push(lyr);
			addChild(lyr.wrapper);

			return lyr;
		}

		public function set rotationXaxis(r:Number):void {
			mRotationX = r;

			if (mAutoUpdateTransform)
				buildMatrix();
		}

		public function get rotationXaxis():Number {
			return mRotationX;
		}

		public function set rotationZaxis(r:Number):void {
			mRotationZ = r;

			if (mAutoUpdateTransform)
				buildMatrix();
		}

		public function get rotationZaxis():Number {
			return mRotationZ;
		}


		private function buildMatrix():void
		{
			var mrz:M44 = (new M44()).rotZ(mRotationZ);
			var mrx:M44 = (new M44()).rotX(mRotationX);

			var m:M44 = new M44();
			m.mul(mrz, mrx);
			mZYFactor = m._32;

			mMapTrans2D.a = m._11;
			mMapTrans2D.b = m._12;

			mMapTrans2D.c = m._21;
			mMapTrans2D.d = m._22;

			mMapTrans2D.tx = int(mScreenWidth/2);
			mMapTrans2D.ty = int(mScreenHeight/2) - (mRotationX*100);

			mMapContainer.transform.matrix = mMapTrans2D;
			setOverlaysTransform();
		}

		public function setOverlaysTransform():void
		{
			if (!mLayerStack) return;

			var list:Array = mLayerStack;
			var len:int    = list.length;
			for (var i:int = 0;i < len;i++) {
				var lyr:FGMapLayer = list[i] as FGMapLayer;
				lyr.transform.matrix = mMapTrans2D;
				lyr.altOffsetY = -Number(mLayerAltStack[i+1]) * mAltScale * mZYFactor;
				lyr.y = mMapTrans2D.ty + lyr.altOffsetY;

				lyr.afterTransformUpdated();
			}
		}

		public function calcAltMeter(m:Number):Number
		{
			return mAltScale * m;
		}

		public function pixToLatLng(px:Point, ll:FLatLngAlt, useTransform:Boolean = true):void
		{
			var itrans:Matrix = invRotationTranform;
			var gmap:Map = mGMap;
			var sz:Number = GMapCalc.calcMapSize(gmap.getZoom());

			// var pt1:Point = new Point();
			var ptC:Point = new Point();

			var cll:com.google.maps.LatLng = gmap.getCenter();
			GMapCalc.LatLngToXY(cll.lat() * DEGTORAD, cll.lng() * DEGTORAD, ptC);
			ptC.x *= sz;
			ptC.y *= sz;

			if (useTransform) {
				ptC.x += itrans.a * px.x + itrans.c * px.y;// + itrans.tx;
				ptC.y += itrans.b * px.x + itrans.d * px.y;// + itrans.ty;
			}
			else {
				ptC.x += px.x;
				ptC.y += px.y;
			}

			ptC.x /= sz;
			ptC.y /= sz;

			GMapCalc.XYtoLatLng(ptC.x, ptC.y, ll);
			ll.lat /= DEGTORAD;
			ll.lng /= DEGTORAD;
		}

		public function calcScreenPos(lat:Number, lng:Number, out:Point, useTransform:Boolean = true):void
		{
			var trans:Matrix = mMapTrans2D;
			var gmap:Map = mGMap;

			var ll:com.google.maps.LatLng = gmap.getCenter();
			var sz:Number = GMapCalc.calcMapSize(gmap.getZoom());
			var ptC:Point = new Point();

			GMapCalc.LatLngToXY(ll.lat() * DEGTORAD, ll.lng() * DEGTORAD, ptC);

			GMapCalc.LatLngToXY(lat * DEGTORAD, lng * DEGTORAD, out);

			out.x *= sz;
			out.y *= sz;
			ptC.x *= sz;
			ptC.y *= sz;

			out.x -= ptC.x;
			out.y -= ptC.y;

			if (useTransform) {
				var tx:Number = out.x;
				var ty:Number = out.y;
				out.x = trans.a * tx + trans.c * ty + trans.tx;
				out.y = trans.b * tx + trans.d * ty + trans.ty;
			}
		}

		public function get mapTrans2D():Matrix
		{
			return mMapTrans2D
		}

		public function get invRotationTranform():Matrix
		{
			var m:Matrix = mMapTrans2D.clone();

			var det:Number = m.a * m.d - m.b * m.c;

			var t:Number = m.a;
			m.a = m.d / det;
			m.d = t / det;
			m.b *= -1.0 / det;
			m.c *= -1.0 / det;

			return m;
		}
	}
}
