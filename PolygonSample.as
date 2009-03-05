package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

	import com.google.maps.MapEvent;
	import com.google.maps.LatLng;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapAction;
	import com.google.maps.controls.*;
	import com.google.maps.MapType;

	import org.libspark.thread.*;

	import fgmap.*;
	import fgmap.xmap.*;
	import fgmap.feature.*;
	import fgmap.xmap.events.*;

	public class PolygonSample extends STDOUT implements IRollMap
	{
		public static const DPI:Number = Math.PI * 2.0;

		private var mScreenWidth:uint;
		private var mScreenHeight:uint;
		private static const SCR_VMARGIN:int = 160;
		private static const SCR_HMARGIN:int = 220;

		private var mMap:FGMap;
		private var mPolygonsLayer:FGMapLayer;
		private var mEditorLayer:FGMapLayer;
		private var mEditorCtrl:EditorController;
		private var mRollCtrl:RollController;
		private var mTypeCtrl:MapTypeControl;

		private var mSelectedPolygon:FGPolygonFeature = null;

		// Entry Point
		function PolygonSample()
		{
			Thread.initialize(new EnterFrameThreadExecutor());

			mMap = new FGMap("ABQIAAAABxFFkLd0-1pnEhhkOq6s5RQcuLxgX0pplfQI4Ehd2KRFtB1ixRQIZ-M1i4lkRoQOXUu1EYETATSOPw");
			addChild(mMap);

			mMap.gmap.addEventListener(MapEvent.MAP_READY, onMapReady);

			// update screen after dragging (no wait for enter_frame)
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);

			mMap.gmap.addEventListener(MapMouseEvent.DOUBLE_CLICK, onMapDblClick);
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

			mRollCtrl = new RollController(this);
			addChild(mRollCtrl);
			mRollCtrl.y = 8;

			mTypeCtrl = new MapTypeControl();
			addChild(mTypeCtrl);
			mTypeCtrl.initControlWithMap(mMap.gmap);
			mTypeCtrl.y = 7;

			// setup layers
			mPolygonsLayer = new FGMapLayer({clip: false, showBorder: false});
			mMap.pushLalyer(mPolygonsLayer);

			mEditorLayer = new FGMapLayer({clip: false, showBorder:false});
			mMap.pushLalyer(mEditorLayer);
			mMap.bringupLayer(-1);

			mEditorCtrl = new EditorController(mEditorLayer);
			mEditorCtrl.addEventListener(PolygonEditorEvent.HANDLE_STEP,    onEditHandleStep);

			mMap.gmap.setDoubleClickMode(MapAction.ACTION_NOTHING);
			mMap.gmap.setCenter(new LatLng(35.66,139.718), 18);
			onResize(null);
		}

		private function onMapDblClick(e:MapMouseEvent):void
		{
			e.stopPropagation();

			putNewPolygon(e.latLng);
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

			mRollCtrl.x = stage.stageWidth - 80;
			mTypeCtrl.x = mRollCtrl.x - 150;

			if (mMap)
				adjustMapSize();
		}

		private function adjustMapSize():void
		{
			mMap.setSize(new Point(mScreenWidth, mScreenHeight));
		}

		public function set mapAngle(r:Number):void
		{
			if (r < 0)    r += DPI;
			if (r >= DPI) r -= DPI;
			mMap.rotationZaxis = r;
		}

		public function putNewPolygon(ll:LatLng):void
		{
			var polygon:FGPolygonFeature = new FGPolygonFeature();
			polygon.addVertex(ll.lat() + 0.0002, ll.lng());
			polygon.addVertex(ll.lat() - 0.0002, ll.lng() + 0.0002);
			polygon.addVertex(ll.lat() - 0.0002, ll.lng() - 0.0002);

			polygon.sweep = 10 + int(Math.random()*60);
			polygon.alpha = 0.9;
			polygon.clientData.oliginalSweep = polygon.sweep;

			polygon.buttonMode = true;
			polygon.addEventListener(MouseEvent.CLICK, onPolygonClick);

			mPolygonsLayer.addFeature(polygon);
			selectPolygon(polygon);
		}

		private function selectPolygon(polygon:FGPolygonFeature):void
		{
			if (mSelectedPolygon == polygon && mSelectedPolygon)
			{
				enablePolygonEditMode(!polygon.clientData.editMode, polygon);
				return;
			}

			if (mSelectedPolygon)
				enablePolygonEditMode(false, mSelectedPolygon);

			mSelectedPolygon = polygon;
			if (mSelectedPolygon)
				enablePolygonEditMode(true, mSelectedPolygon);
		}

		private function enablePolygonEditMode(b:Boolean, polygon:FGPolygonFeature):void
		{
			polygon.sweep = b ? 0 : polygon.clientData.oliginalSweep;
			polygon.clientData.editMode = b;
			if (b) {
				mEditorCtrl.putHandles(polygon);
				// hideOtherBuildings(pg);
			} else {
				mEditorCtrl.clearHandles();
				// hideOtherBuildings(null);
			}

			mPolygonsLayer.updateVisuals();
		}

		private function onEditHandleStep(e:PolygonEditorEvent):void
		{
			mPolygonsLayer.updateVisuals();
		}

		private function onPolygonClick(e:MouseEvent):void
		{
			if (e.target is FGPolygonFeature) {
				var polygon:FGPolygonFeature = e.target as FGPolygonFeature;
				selectPolygon(polygon);
			}
		}
	}
}
