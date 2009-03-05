package fgmap.xmap
{
	import fgmap.*;
	import fgmap.feature.*;
	import flash.events.*;
	import flash.geom.*;
	import fgmap.xmap.events.*;

	public class EditorController extends EventDispatcher
	{
		private var mEditorLayer:FGMapLayer;
		private var mCurrentBPolygon:FGPolygonFeature;
		public static const MAX_VERTICES:int = 10;

		function EditorController(el:FGMapLayer)
		{
			mEditorLayer = el;
		}

		public function clearHandles():void
		{
			for each(var f:FGFeature in mEditorLayer.childMap) {
				f.removeEventListener(MouseEvent.MOUSE_DOWN, onHandleMouseDown);
				f.removeEventListener(MouseEvent.MOUSE_UP,   onHandleMouseUp);
				f.removeEventListener(MouseEvent.MOUSE_MOVE, onHandleMouseMove);

				f.removeEventListener(MouseEvent.MOUSE_DOWN, onFoldHandleMouseDown);
				f.removeEventListener(MouseEvent.MOUSE_UP,   onFoldHandleMouseUp);
				f.removeEventListener(MouseEvent.MOUSE_MOVE, onFoldHandleMouseMove);
			}

			mEditorLayer.clear();
		}

		public function putHandles(pg:FGPolygonFeature):void
		{
			var vertices:Array = pg.vertices;
			if (!vertices) throw "null vertices";

			var first:EditHandle = null;
			var prev:EditHandle = null;
			var h:EditHandle;
			var i:int = 0;
			for each(var ll:FLatLngAlt in vertices) {

				h = new EditHandle();
				h.hotX = 4;
				h.hotY = 4;
				h.clientData.ll = ll;
				h.redrawHook = hookRedrawHandle;
				h.vIndex = i++;

				mEditorLayer.addFeature(h);
				h.useHandCursor = false;
				h.buttonMode = true;
				h.addEventListener(MouseEvent.MOUSE_DOWN, onHandleMouseDown);
				h.addEventListener(MouseEvent.MOUSE_UP,   onHandleMouseUp);
				h.addEventListener(MouseEvent.MOUSE_MOVE, onHandleMouseMove);

				if (!first)
					first = h;
				else {
					putFoldHandle(prev, h);
					prev.cwNext = h;
				}

				h.ccwPrev = prev;
				prev = h;
			}
			h.cwNext = first;
			first.ccwPrev = h;

			putFoldHandle(h, first);
			mCurrentBPolygon = pg;
		}

		private function putFoldHandle(ph:EditHandle, nh:EditHandle):void
		{
			var fh:EditHandle = new EditHandle(true);
			fh.hotX = 4;
			fh.hotY = 4;

			fh.useHandCursor = false;
			fh.buttonMode = true;
			fh.addEventListener(MouseEvent.MOUSE_DOWN, onFoldHandleMouseDown);
			fh.addEventListener(MouseEvent.MOUSE_UP,   onFoldHandleMouseUp);
			fh.addEventListener(MouseEvent.MOUSE_MOVE, onFoldHandleMouseMove);

			fh.ccwPrev = ph;
			fh.cwNext  = nh;

			fh.redrawHook = hookRedrawFoldHandle;
			mEditorLayer.addFeature(fh);
		}

		private function hookRedrawHandle(h:EditHandle):void
		{
			h.putAtLL(h.clientData.ll as FLatLngAlt, mEditorLayer.ownerMap);
		}

		private function hookRedrawFoldHandle(fh:EditHandle):void
		{
			var ll:FLatLng = (fh.ccwPrev.clientData.ll as FLatLng).clone();
			var ll2:FLatLng = fh.cwNext.clientData.ll as FLatLng;

			ll.lat = 0.5 * (ll.lat+ll2.lat);
			ll.lng = 0.5 * (ll.lng+ll2.lng);

			fh.putAtLL(ll, mEditorLayer.ownerMap);
		}

		private function onHandleMouseDown(e:MouseEvent):void
		{
			var h:EditHandle = e.target as EditHandle;
			h.expandHitArea(true);
		}

		private function onHandleMouseUp(e:MouseEvent):void
		{
			var h:EditHandle = e.target as EditHandle;
			h.expandHitArea(false);
		}

		private function onHandleMouseMove(e:MouseEvent):void
		{
			var h:EditHandle = e.target as EditHandle;
			if (e.buttonDown) {
				var ll:FLatLngAlt = new FLatLngAlt(0, 0);
				mEditorLayer.ownerMap.pixToLatLng(new Point(mEditorLayer.mouseX, mEditorLayer.mouseY), ll, false);
				h.clientData.ll.lat = ll.lat;
				h.clientData.ll.lng = ll.lng;
				mEditorLayer.updateVisuals();

				var ee:PolygonEditorEvent = new PolygonEditorEvent(PolygonEditorEvent.HANDLE_STEP);
				dispatchEvent(ee);

			 	checkUnfold(h);
			}
			else {
				h.expandHitArea(false);
			}
		}

		// Fold Handle Events
		private function onFoldHandleMouseDown(e:MouseEvent):void
		{
			var h:EditHandle = e.target as EditHandle;
			h.expandHitArea(true);
		}

		private function onFoldHandleMouseUp(e:MouseEvent):void
		{
			var h:EditHandle = e.target as EditHandle;
			h.expandHitArea(false);
		}

		private function onFoldHandleMouseMove(e:MouseEvent):void
		{
			var h:EditHandle = e.target as EditHandle;
			if (e.buttonDown) {
				var mx:Number = h.mouseX;
				if (mx<0) mx=-mx;

				var my:Number = h.mouseY;
				if (my<0) my=-my;

				if (mx > 8 || my > 8) {
					foldAfter(h.ccwPrev);
				}
			}
			else {
				h.expandHitArea(false);
			}
		}

		private function foldAfter(h:EditHandle):void
		{
			if (!mCurrentBPolygon) throw "not selected!";
			if (mCurrentBPolygon.vertices.length >= MAX_VERTICES) return;

			var ll:FLatLngAlt = new FLatLngAlt(0, 0);
			mEditorLayer.ownerMap.pixToLatLng(new Point(mEditorLayer.mouseX, mEditorLayer.mouseY), ll, false);

			mCurrentBPolygon.insertVertexAfter(h.vIndex, ll.lat, ll.lng);
			clearHandles();
			putHandles(mCurrentBPolygon);

			var ee:PolygonEditorEvent = new PolygonEditorEvent(PolygonEditorEvent.VERTEX_CREATED);
			ee.nVertices = mCurrentBPolygon.vertices.length;
			dispatchEvent(ee);
		}

		private function unfold(h:EditHandle):void
		{
			if (mCurrentBPolygon.vertices.length < 4) return;

			mCurrentBPolygon.removeVertexAt(h.vIndex);
			clearHandles();
			putHandles(mCurrentBPolygon);
			mCurrentBPolygon.owner.updateVisuals();
		}

		private function checkUnfold(h:EditHandle):void
		{
			var x1:Number = h.ccwPrev.x - h.x;
			var y1:Number = h.ccwPrev.y - h.y;

			var x2:Number = h.cwNext.x - h.x;
			var y2:Number = h.cwNext.y - h.y;

			var n1:Number = Math.sqrt(x1*x1 + y1*y1);
			var n2:Number = Math.sqrt(x2*x2 + y2*y2);

			var dot_product:Number = (x1/n1)*(x2/n2) + (y1/n1)*(y2/n2);
			if (dot_product < -0.9 && h.unfoldOK) {
				unfold(h);
			} else if (dot_product > -0.8) {
				h.unfoldOK = true;
			}
		}
	}
}