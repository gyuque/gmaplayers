package fgmap.feature
{
	import fgmap.*;
	import fgmap.utils.ColorCalc;
	import flash.utils.Dictionary;
	import flash.display.*;
	import flash.geom.*;
	import fgmap.trans.*;
	import flash.geom.*;

	public class FGPolygonFeature extends FGFeature
	{
		private var mNeedsSort:Boolean;
		private var mVertices:Array;
		private var mTexMap:Dictionary = null;
		private var mSweep:Number = 0;
		private var mFloatAlt:Number = 0;
		private var mYMax:Number, mYMin:Number;
		private var mXMax:Number, mXMin:Number;

		private var mBaseColor:uint = 0x5587dd;
		private var mEdgeColor:uint = 0x6587fd;
		private var mPrevRenderWalls:Array = null;

		private var mEdgeWidth:int = 0;

		private var mColorOverrideIndices:Array = null;
		private var mColorOverrideColors: Array = null;

		private var mCulling:Number = 0;
		private var mHitTestOffscreen:Sprite = null;

		private var mAttachedIcons:Array;

		function FGPolygonFeature()
		{
			mNeedsSort = true;
			mVertices = [];
		}

		public function setColorOverride(i:uint, c:uint):void
		{
			if (!mColorOverrideIndices) mColorOverrideIndices = [null];
			if (!mColorOverrideColors)  mColorOverrideColors  = [0];

			mColorOverrideIndices[0] = i;
			mColorOverrideColors[0]  = c;
		}

		public function removeColorOverride():void
		{
			if (!mColorOverrideIndices) return;
			
			mColorOverrideIndices[0] = null;
		}

		public function set edgeWidth(ew:uint):void
		{
			mEdgeWidth = ew;
		}

		public function setTextureAt(i:uint, b:BitmapData):void
		{
			if (!mTexMap)
				mTexMap = new Dictionary();

			mTexMap[i] = b;
		}

		public function getTextureAt(i:uint):BitmapData
		{
			if (!mTexMap)
				return null;
			
			return mTexMap[i] || null;
		}

		public function attachIcon(i:FGIconFeature, fi:int, hpos:Number, altpos:Number):void
		{
			if (!mAttachedIcons)
				mAttachedIcons = [];

			i.faceIndex = fi;
			i.altpos = altpos;
			i.hpos = hpos;

			mAttachedIcons.push(i);
			addChild(i);
		}

		public function get attachedIcons():Array
		{
			return mAttachedIcons;
		}

		public function disposeAllTexture(ignoreThis:BitmapData = null):void
		{
			for (var i:Object in mTexMap) {
				if (!mTexMap[i] || mTexMap[i] == ignoreThis) continue;

				mTexMap[i].dispose();
				mTexMap[i] = null;
			}

		}

		public function copyVertices(frm:FGPolygonFeature):void
		{
			for each(var sp:FLatLngAlt in frm.mVertices) {
				mVertices.push( new FLatLngAlt(sp.lat, sp.lng, sp.alt) );
			}
		}

		public function get vertices():Array
		{
			return mVertices;
		}

		public function set floatAlt(a:Number):void
		{
			mFloatAlt = a;
		}

		public function set needsSort(s:Boolean):void
		{
			mNeedsSort = s;
		}

		public function set sweep(s:Number):void
		{
			mSweep = s;
		}

		public function get sweep():Number
		{
			return mSweep;
		}
		
		public function set baseColor(c:uint):void
		{
			mBaseColor = c;
		}

		public function set edgeColor(c:uint):void
		{
			mEdgeColor = c;
		}

		public override function get independentTransform():Boolean {
			return true;
		}

		public override function get useSorter():Boolean
		{
			return mNeedsSort;
		}

		public override function redraw(m:FGMap):void
		{
			var n:int = mVertices.length;
			if (n < 3)
				return;

			var i:int;
			var pt:Point = new Point();
			var pt1:Point = new Point();
			var ll:FLatLngAlt;

			var g:Graphics = graphics;
			g.clear();

			var pxFloat:Number = m.calcAltMeter(mFloatAlt);
			var pxAlt:Number = m.calcAltMeter(mSweep);
			if (pxAlt < -0.5 || pxAlt > 0.5)
				drawWalls(g, m, pxAlt, pxFloat);

			var hf:Boolean = shouldHighlightFace();

			g.beginFill(mBaseColor, hf ? 0.5 : 1);
			if (mEdgeWidth > 0.5)
				g.lineStyle(mEdgeWidth, mEdgeColor, hf ? 0.3 : 1);
			mYMin = Infinity;
			mYMax = -Infinity;
			mXMin = Infinity;
			mXMax = -Infinity;
			for (i = 0;i < n;i++)
			{
				ll = mVertices[i] as FLatLngAlt;
				calcScreenPos(m, ll, pt);

				if (mYMax < pt.y)
					mYMax = pt.y;
				if (mYMin > pt.y)
					mYMin = pt.y;

				if (mXMax < pt.x)
					mXMax = pt.x;
				if (mXMin > pt.x)
					mXMin = pt.x;

				pt.y -= pxAlt + pxFloat;

				if (i == 0) {
					g.moveTo(pt.x, pt.y);
					pt1.x = pt.x;
					pt1.y = pt.y;
				}
				else
					g.lineTo(pt.x, pt.y);
			}

			g.lineTo(pt1.x, pt1.y);
			g.endFill();

			locateIcons(m);

			if (mRedrawHook != null)
				mRedrawHook(this);

			if (mAttachedIcons) {
				for each(var ai:FGIconFeature in mAttachedIcons) {
					ai.redraw(m);
				}
			}
		}

		private function locateIcons(m:FGMap):void
		{
			if (!mAttachedIcons) return;

			for each(var i:FGIconFeature in mAttachedIcons) {
				i.visible = calcPositionOnFace(i, m, i.faceIndex, i.hpos, i.altpos);
			}
		}

		private function drawHitTestWalls(g:Graphics, m:FGMap):void
		{
			var pxFloat:Number = m.calcAltMeter(mFloatAlt);
			var pxAlt:Number = m.calcAltMeter(mSweep);
			if (pxAlt < -0.5 || pxAlt > 0.5)
				drawWalls(g, m, pxAlt, pxFloat, true);
		}

		public override function calcCenterY():int
		{
			return (mYMin + mYMax)/2;
		}

		public function calcCenterX():int
		{
			return (mXMin + mXMax)/2;
		}

		public function drawWalls(g:Graphics, m:FGMap, pxalt:Number, pxfloat:Number = 0, htmode:Boolean = false):void
		{
			var ll: FLatLngAlt;
			var ll2:FLatLngAlt;
			var pt:Point = new Point();
			var i:int;
			var n:int = mVertices.length;

			var walls:Array = [];

			for (i = 0;i < n;i++)
			{
				ll  = mVertices[i      ] as FLatLngAlt;
				ll2 = mVertices[(i+1)%n] as FLatLngAlt;

				var w:WallData = new WallData();

				w.index = i;
				calcScreenPos(m, ll , w.p1);
				calcScreenPos(m, ll2, w.p2);
				w.calcCenter();
				walls.push(w);
			}

			walls.sortOn('zsort_key');
			renderWallList(g, walls, pxalt, pxfloat, htmode);
			mPrevRenderWalls = walls;
		}

		public function calcFirstScreenPos(pt:Point, m:FGMap):void
		{
			var pxFloat:Number = m.calcAltMeter(mFloatAlt);
			var ll:FLatLngAlt = mVertices[0] as FLatLngAlt;
			calcScreenPos(m, ll, pt);
			pt.y -= pxFloat;
		}

		private function shouldHighlightFace():Boolean
		{
			return (mColorOverrideIndices && mColorOverrideIndices[0] != null && mColorOverrideIndices[0] < mVertices.length);
		}

		public function getFrontFaceIndex(m:FGMap):int
		{
			var ll: FLatLngAlt;
			var ll2:FLatLngAlt;
			var i:int, n:int = mVertices.length;

			var w:WallData = new WallData();
			for (i = (n-1);i >= 0;i--)
			{
				ll  = mVertices[i      ] as FLatLngAlt;
				ll2 = mVertices[(i+1)%n] as FLatLngAlt;

				calcScreenPos(m, ll , w.p1);
				calcScreenPos(m, ll2, w.p2);

				if ((w.p1.x - w.p2.x) < 0)
					continue;

				return i;
			}

			return -1;
		}

		private static var sTempOffscreen:BitmapData = null;
		private static var sTempOffscreenRect:Rectangle;
		private static const TEMP_OFS_SIZE:int = 256;
		protected static function get tempOffscreen():BitmapData
		{
			if (!sTempOffscreen) {
				sTempOffscreen     = new BitmapData(TEMP_OFS_SIZE, TEMP_OFS_SIZE, false);
				sTempOffscreenRect = new Rectangle(0, 0, TEMP_OFS_SIZE, TEMP_OFS_SIZE);
			}

			return sTempOffscreen;
		}

		private function pickRenderWall(i:int):WallData
		{
			for each(var w:WallData in mPrevRenderWalls) {
				if (w.index == i) return w;
			}

			return null;
		}

		public function doFaceHitTest(m:FGMap):PolygonHitTestData
		{
			if (!mHitTestOffscreen)
				 mHitTestOffscreen = new Sprite();

			var g:Graphics = mHitTestOffscreen.graphics;
			g.clear();

			var cul_old:Number = mCulling;
			mCulling = 1;
			drawHitTestWalls(g, m);
			if (!mPrevRenderWalls)
				return null;
			mCulling = cul_old;

			if (mHitTestOffscreen.width > 1 && mHitTestOffscreen.height > 1) {
//var _add:Boolean = !sTempOffscreen;
				var b:BitmapData = tempOffscreen;
/*
if (_add) {
var bm:Bitmap = new Bitmap( sTempOffscreen );
bm.x = 200;
bm.y = 200;
addChild( bm );
}*/

				b.fillRect(sTempOffscreenRect, 0xffffffff);
				var rw:Number = b.width  / mHitTestOffscreen.width;
				var rh:Number = b.height / mHitTestOffscreen.height;

				var bbox:Rectangle = mHitTestOffscreen.getRect(mHitTestOffscreen);
				var trans:Matrix = new Matrix();
				trans.a = rw;
				trans.d = rh;
				trans.tx = -bbox.x * rw;
				trans.ty = -bbox.y * rh;
				b.draw(mHitTestOffscreen, trans);

				var pickX:int = (mouseX-bbox.x)*rw;
				var pickY:int = (mouseY-bbox.y)*rh;

				var k:uint = b.getPixel(pickX, pickY);
				if (k > 0 && k < 10000) {
					g.clear();
					var result:PolygonHitTestData = new PolygonHitTestData();
					result.faceIndex = int(k/100);

					var hitWall:WallData = pickRenderWall(result.faceIndex);
					var vX:Point = hitWall.p2.clone();
					vX.x -= hitWall.p1.x;
					vX.y -= hitWall.p1.y;
					var vY:Point = new Point(0, -m.calcAltMeter(1));
/*
STDOUT.puts(vY);
graphics.lineStyle(2,0xff0000);
graphics.moveTo(hitWall.p1.x, hitWall.p1.y);
graphics.lineTo(hitWall.p2.x, hitWall.p2.y);
*/
					var clickPt:Point = new Point(mouseX - hitWall.p1.x, mouseY - hitWall.p1.y);
					if (MathUtil.resolveVec2(clickPt, vX, vY)) {

						result.hPosition = clickPt.x;
						result.alt       = clickPt.y;

						return result;
					}
				}

			}

			g.clear();
			return null;
		}

		public function calcPositionOnFace(out:Object, m:FGMap, fi:int, hPos:Number, alt:Number):Boolean
		{
			var ll :FLatLngAlt = mVertices[fi                     ] as FLatLngAlt;
			var ll2:FLatLngAlt = mVertices[(fi+1)%mVertices.length] as FLatLngAlt;

			var w:WallData = new WallData();
			calcScreenPos(m, ll , w.p1);
			calcScreenPos(m, ll2, w.p2);

			out.x = w.p1.x * (1.0-hPos) + w.p2.x * hPos;
			out.y = w.p1.y * (1.0-hPos) + w.p2.y * hPos - m.calcAltMeter(alt);

			return (w.p1.x - w.p2.x) >= 0;
		}

		public function renderWallList(g:Graphics, list:Array, pxalt:Number, pxfloat:Number, htmode:Boolean = false):void
		{
			var v1:Point = new Point();
			var v2:Point = new Point();
			var ttrans:Matrix = new Matrix();

			var pt:Point;
			var plist:Array = new Array(4);
			plist[0] = new Point();
			plist[1] = new Point();

			if (shouldHighlightFace() || htmode)
				g.lineStyle();
			else
				g.lineStyle(mEdgeWidth, mEdgeColor);

			for each(var w:WallData in list) {
				plist[2] = w.p2;
				plist[3] = w.p1;
				v2.x = w.p2.x;
				v2.y = w.p2.y;

				pt = Point(plist[0]);
				pt.x = w.p1.x;
				pt.y = w.p1.y - pxalt;
				v1.x = -pt.x; v1.y = -pt.y;

				pt = Point(plist[1]);
				pt.x = w.p2.x;
				pt.y = w.p2.y - pxalt;
				v1.x += pt.x; v1.y += pt.y;
				v2.x -= pt.x;
				v2.y -= pt.y;

				if (MathUtil.cp2(v1.x, v1.y, v2.x, v2.y)*mCulling > 0) {
					continue;
				}

				var dc:uint;
				var texb:BitmapData = mTexMap ? (mTexMap[w.index] as BitmapData) : null;

				if (htmode) {
					// Hit Test Mode. No texture.
					texb = null;
					dc = w.index * 100 + 50;
				}
				else {
					dc = ColorCalc.darkenColor(mBaseColor, 22);
				}

				if (texb) { // has texture
					calcTexTrans(plist, ttrans, texb);
					g.beginBitmapFill(texb, ttrans);
				}
				else
					g.beginFill(dc);

				g.moveTo(Point(plist[0]).x, Point(plist[0]).y);
				g.lineTo(Point(plist[1]).x, Point(plist[1]).y);
				g.lineTo(Point(plist[2]).x, Point(plist[2]).y);
				g.lineTo(Point(plist[3]).x, Point(plist[3]).y);

				g.endFill();

				if (mColorOverrideIndices && mColorOverrideIndices[0] == w.index) {
					g.lineStyle(mEdgeWidth, mColorOverrideColors[0]);
					g.beginFill(mColorOverrideColors[0], 0.6);
					g.moveTo(Point(plist[0]).x, Point(plist[0]).y);
					g.lineTo(Point(plist[1]).x, Point(plist[1]).y);
					g.lineTo(Point(plist[2]).x, Point(plist[2]).y);
					g.lineTo(Point(plist[3]).x, Point(plist[3]).y);
					g.endFill();
					g.lineStyle();
				}			
			}
			g.lineStyle();
		}

		public static function calcTexTrans(plist:Array, m:Matrix, t:BitmapData):void
		{
			var v0:Point = Point(plist[1]); // not clone!
			var vA:Point = Point(plist[0]).clone();
			var vB:Point = Point(plist[2]).clone();

			m.tx = v0.x;
			m.ty = v0.y;

			vA.x = v0.x - vA.x;
			vA.y = v0.y - vA.y;

			vB.x = v0.x - vB.x;
			vB.y = v0.y - vB.y;


			var bx:Number = t.width;
			var by:Number = t.height;
			var det:Number = 1.0 / (bx*by);

			bx *= -det;
			by *= -det;

			m.a = by * vA.x; 
			m.b = by * vA.y; 
			m.c = bx * vB.x; 
			m.d = bx * vB.y; 
		}

		private static function vec_nrm(v:Point):Number {
			return Math.sqrt(v.x*v.x + v.y*v.y);
		}

		private static function near_zero(v:Number):Boolean {
			return (v > -0.01) && (v < 0.01);
		}

		public function addVertex(lat:Number, lng:Number, alt:Number = 0):void
		{
			var v:FLatLngAlt = new FLatLngAlt(lat, lng, alt);
			mVertices.push(v);
		}

		public function insertVertexAfter(i:int, lat:Number, lng:Number, alt:Number = 0):void
		{
			mVertices.push(null);

			var len:int = mVertices.length;
			if (len > 2 && i < (len-1))
			{
				for (var k:int = (len-1);k >= (i+2);k--) {
					mVertices[k] = mVertices[k-1];
				}
			}

			mVertices[i+1] = new FLatLngAlt(lat, lng, alt);
		}

		public function removeVertexAt(i:int):void
		{
			if (mVertices.length < 4) return;

			mVertices.splice(i, 1);
		}
	}
}

class WallData
{
	import flash.geom.*;

	public var index:int;
	public var p1:Point = new Point();
	public var p2:Point = new Point();
	public var pc:Point = new Point();

	public function calcCenter():void {
		pc.x = (p1.x+p2.x)/2;
		pc.y = (p1.y+p2.y)/2;

		zsort_key = pc.y*100.0;
	}
	public var zsort_key:int;
}