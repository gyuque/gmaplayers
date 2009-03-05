package
{
	import flash.external.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapAction;
	import com.google.maps.controls.*;
	import com.google.maps.MapEvent;
	import com.google.maps.MapType;
	import com.google.maps.LatLng;

	import org.libspark.thread.*;

	import fgmap.*;
	import fgmap.xmap.*;
	import fgmap.feature.*;
	import fgmap.xmap.events.*;

	import org.libspark.thread.*;
	import caurina.transitions.Tweener;

	public class LayerSample extends STDOUT implements IRollMap
	{
		private var mScreenWidth:uint;
		private var mScreenHeight:uint;
		private static const SCR_VMARGIN:int = 160;
		private static const SCR_HMARGIN:int = 220;

		public static const DPI:Number = Math.PI * 2.0;
		private static const NUM_LAYERS:int = 4;

		private static const RX_ANGLE:Number = 0.56;
		private static const RZ_ANGLE:Number = 0.2;

		private var mMap:FGMap;
		private var mTypeCtrl:MapTypeControl;
		private var mLayers:Array;
		private var mFadeSprite:Sprite = new Sprite();
		private var mSelectedLayer:FGMapLayer = null;

		private var mInSelectMode:Boolean = false;

		[Embed(source="./sample_images/daiba_74.jpg")]
		private static const Image74:Class;

		[Embed(source="./sample_images/daiba_79.jpg")]
		private static const Image79:Class;

		[Embed(source="./sample_images/daiba_89.jpg")]
		private static const Image89:Class;

		private static const LABELS:Array = ["Current", "1989", "1979", "1974"];

		private var mLayerImages:Array;

		// Entry Point
		function LayerSample()
		{
			ExternalInterface.addCallback("selectMode", selectMode);
			Thread.initialize(new EnterFrameThreadExecutor());
			mLayerImages = [
				(new Image89()).bitmapData,
				(new Image79()).bitmapData,
				(new Image74()).bitmapData
			];

			mMap = new FGMap("ABQIAAAABxFFkLd0-1pnEhhkOq6s5RQcuLxgX0pplfQI4Ehd2KRFtB1ixRQIZ-M1i4lkRoQOXUu1EYETATSOPw");
			addChild(mMap);

			mMap.gmap.addEventListener(MapEvent.MAP_READY, onMapReady);

			// update screen after dragging (no wait for enter_frame)
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
		}
		// next
		// Initialize Google Maps
		private function onMapReady(e:MapEvent):void
		{
			mMap.gmap.removeMapType(MapType.HYBRID_MAP_TYPE);
			mMap.gmap.removeMapType(MapType.PHYSICAL_MAP_TYPE);

			// Setup Controllers
			var zc:ZoomControl = new ZoomControl();
			addChild(zc);
			zc.initControlWithMap(mMap.gmap);
			zc.x = 8;
			zc.y = 14;

			mTypeCtrl = new MapTypeControl();
			addChild(mTypeCtrl);
			mTypeCtrl.initControlWithMap(mMap.gmap);
			mTypeCtrl.y = 7;

			mMap.gmap.setCenter(new LatLng(35.621512,139.778581), 15);
			mMap.addChild(mFadeSprite);
			mFadeSprite.mouseEnabled = false;
			mFadeSprite.alpha = 0;
			setupLayers();
			mMap.setOverlaysTransform();
removeChild(tx);
addChild(tx);
tx.width = 400;
tx.height = 400;

			onResize(null);
		}

		private function setupLayers():void
		{
			mLayers = new Array(NUM_LAYERS);

			for (var i:int = 0;i < NUM_LAYERS;i++)
			{
				var rc:FGRectFeature = new FGRectFeature(35.626465, 139.767944, 35.616421, 139.786819);
				var lyr:FGMapLayer = new FGMapLayer({clip: false, showBorder: false});
				mMap.pushLalyer(lyr);
				if (i)
					mMap.bringupLayer(399);

				mLayers[i] = lyr;
				observeLayer(lyr);
				
				rc.borderColor = 0xffffff;
				lyr.addFeature(rc);
				if (i)
					rc.texture = mLayerImages[i-1];
				else {
					rc.clientData.dummy = true;
					rc.fillAlpha = 0.2;
					rc.fillColor = 0xffffff;
				}

				var label:LayerLabel = new LayerLabel(LABELS[i]);
				lyr.addChild(label);
				rc.clientData.layerlabel = label;
				label.visible = false;
				rc.redrawHook = onRectRedraw;
			}

			mSelectedLayer = mLayers[0];
			showOtherLayers(false);
		}

		private function onRectRedraw(rc:FGRectFeature):void
		{
			var l:LayerLabel = rc.clientData.layerlabel as LayerLabel;
			var bounds:Rectangle = rc.getRect(rc);
			
			l.x = bounds.x + 10;
			l.y = bounds.y + bounds.height - 40;
		}

		public function get rotationXaxis():Number {
			return mMap.rotationXaxis;
		}

		public function set rotationXaxis(r:Number):void {
			mMap.rotationXaxis = r;
			mMap.updateVisuals();
		}

		public function set mapAngle(r:Number):void
		{
			if (r < 0)    r += DPI;
			if (r >= DPI) r -= DPI;
			mMap.rotationZaxis = r;
		}

		private function onMouseMove(e:MouseEvent):void
		{
			e.updateAfterEvent();
		}

		protected function onResize(e:Event):void
		{
			mScreenWidth  = stage.stageWidth  + SCR_VMARGIN*2;
			mScreenHeight = stage.stageHeight + SCR_HMARGIN*2;

			mMap.x = -SCR_VMARGIN;
			mMap.y = -SCR_HMARGIN;
			mTypeCtrl.x = stage.stageWidth - 140;

			mFadeSprite.graphics.clear();
			mFadeSprite.graphics.beginFill(0, 0.3);
			mFadeSprite.graphics.drawRect(0, 0, mScreenWidth, mScreenHeight);

			if (mMap)
				adjustMapSize();
		}

		private function adjustMapSize():void
		{
			mMap.setSize(new Point(mScreenWidth, mScreenHeight));
		}

		private function observeLayer(lyr:FGMapLayer):void
		{
			lyr.buttonMode = true;
			lyr.addEventListener(MouseEvent.MOUSE_OVER, onLayerMouseOver);
			lyr.addEventListener(MouseEvent.MOUSE_OUT , onLayerMouseOut);

			lyr.addEventListener(MouseEvent.CLICK , onLayerClick);
		}

		private var ColorTrans1:ColorTransform = new ColorTransform(1,1,1,0.9);
		private var ColorTrans2:ColorTransform = new ColorTransform(0.3, 0.5, 1, 1, 20, 50, 130);
		private function onLayerMouseOver(e:MouseEvent):void
		{
			e.target.transform.colorTransform = ColorTrans2;
		}

		private function onLayerMouseOut(e:MouseEvent):void
		{
			e.target.transform.colorTransform = ColorTrans1;
		}

		private function onLayerClick(e:MouseEvent):void
		{
			if (mInSelectMode) {
				var target:Object = e.target;
				if (!(target is FGMapLayer))
					target = target.parent;

				mSelectedLayer = target as FGMapLayer;
				selectMode();
			}
		}

		private function selectMode():void
		{
			if (!mInSelectMode) {
				mInSelectMode = true;

				Tweener.removeAllTweens();
				mMap.rotationXaxis = 0;
				mMap.rotationZaxis = 0;
				Tweener.addTween(mMap, {rotationXaxis: -RX_ANGLE, time:0.5, transition:"easeOutBack"});
				Tweener.addTween(mMap, {rotationZaxis:  RZ_ANGLE, time:0.5, transition:"easeOutBack"});
				showOtherLayers(true);

				Tweener.addTween(mFadeSprite, {alpha: 1, time:0.3, transition:"linear"});
			}
			else {
				mInSelectMode = false;

				Tweener.removeAllTweens();
				mMap.rotationXaxis = -RX_ANGLE;
				mMap.rotationZaxis = RZ_ANGLE;
				Tweener.addTween(mMap, {rotationXaxis: 0, time:0.4, transition:"easeOutCubic"});
				Tweener.addTween(mMap, {rotationZaxis: 0, time:0.4, transition:"easeOutCubic"});
				showOtherLayers(false);

				Tweener.addTween(mFadeSprite, {alpha: 0, time:0.3, transition:"linear"});
			}
		}

		private function showOtherLayers(b:Boolean):void
		{
			for (var i:int = 0;i < NUM_LAYERS;i++) {
				var lyr:FGMapLayer = mLayers[i];
				FGRectFeature(lyr.lastFeature).borderWidth = b ? 1 : undefined;

				if (lyr == mSelectedLayer) {
					lyr.alpha = b ? 0.9 : lyr.lastFeature.clientData.dummy ? 0 : 1;
				}
				else {
					lyr.alpha = b ? 0 : 0.9;
					Tweener.addTween(lyr, {alpha: b ? 0.9 : 0, time:0.3, transition:"linear"});
				}

				lyr.lastFeature.clientData.layerlabel.visible = b;
				lyr.updateVisuals();
				lyr.wrapper.mouseEnabled = lyr.lastFeature.mouseEnabled = lyr.mouseEnabled = b;
			}
		}
	}
}

class LayerLabel extends flash.display.Bitmap
{
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.filters.*;

	private var mData:BitmapData;

	function LayerLabel(s:String)
	{
		mData = new BitmapData(200, 30, true, 0);
		bitmapData = mData;
		smoothing = true;

		var tx:TextField = new TextField();

		var fmt:TextFormat = new TextFormat();
		fmt.bold = true;
		fmt.color = 0xffffff;
		fmt.size = 18;
		fmt.font = "Arial";
		tx.defaultTextFormat = fmt;
		tx.text = s;

		var m:Matrix = new Matrix();
		m.tx = 4;
		m.ty = 4;
		mData.draw(tx, m);

		var f:GlowFilter = new 	GlowFilter(0, 1, 3, 3, 3);
		mData.applyFilter(mData, new Rectangle(0, 0, 200, 30), new Point(0, 0), f);
	}
}
