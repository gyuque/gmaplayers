package fgmap
{
	import flash.display.*;
	import flash.utils.*;
	import fgmap.feature.*;

	public class FGMapLayer extends Sprite
	{
		private var mOwnerMap:FGMap = null;
		private var mClip:Boolean = false;
		private var mShowBorder:Boolean = false;
		private var mRotationWrapper:Sprite = new Sprite();
		private var mAltOffsetY:Number;
		private var mPolygonRenderer:LayerPolygonRenderer = null;
		private var mMaskSprite:Sprite = null;

		private var mFeatures:Dictionary;
		private var mLastFeature:FGFeature = null;

		function FGMapLayer(options:Object) {
			if (options.showBorder)
				mShowBorder = true;

			if (options.clip)
				mClip = true;

			mRotationWrapper.addChild(this);

			mPolygonRenderer = new LayerPolygonRenderer();
			mRotationWrapper.addChild(mPolygonRenderer);
		}

		public override function set visible(v:Boolean):void
		{
			mRotationWrapper.visible = v;
		}

		public override function get visible():Boolean
		{
			return mRotationWrapper.visible;
		}

		public function set altOffsetY(o:Number):void
		{
			mAltOffsetY = o;
		}

		public function get altOffsetY():Number
		{
			return mAltOffsetY;
		}

		public function addFeature(f:FGFeature):void
		{
			if (!mFeatures)
				mFeatures = new Dictionary();

			if (mFeatures[f]) return;

			f.owner = this;
			mFeatures[f] = f;
			if (f.independentTransform) {
				if (f.useSorter)
					mPolygonRenderer.addChild(f);
				else
					mRotationWrapper.addChild(f);
			}
			else
				addChild(f);

			mLastFeature = f;
			updateVisuals();
		}

		public function get childMap():Dictionary
		{
			return mFeatures;
		}

		public function removeFeature(f:FGFeature):void
		{
			if (!mFeatures) return;
			if (!mFeatures[f]) return;

			if (f == mLastFeature)
				mLastFeature = null;

			delete mFeatures[f];
			f.owner = null;
			f.parent.removeChild(f);

			updateVisuals();
		}

		public function removeLastFeature():void
		{
			if (mLastFeature) {
				removeFeature(mLastFeature);
				mLastFeature = null;
			}
		}

		public function clear():void
		{
			var ls:Array = [];
			for each(var f:FGFeature in mFeatures)
				ls.push(f);

			var len:int = ls.length;
			for (var i:int = 0;i < len;i++)
				removeFeature(FGFeature(ls[i]));
		}

		public function get lastFeature():FGFeature
		{
			return mLastFeature;
		}

		public function set ownerMap(m:FGMap):void
		{
			mOwnerMap = m;
			updateVisuals();
		}

		public function get ownerMap():FGMap
		{
			return mOwnerMap;
		}

		public function get wrapper():Sprite
		{
			return mRotationWrapper;
		}

		public function get layerPosX():Number {
			return this.x;
		}

		public function get layerPosY():Number {
			return this.y;
		}

		public function updateVisuals():void
		{
			if (!mOwnerMap)
				return;

			var w:int = mOwnerMap.mapWidth;
			var h:int = mOwnerMap.mapHeight;

			var g:Graphics = graphics;
			g.clear();
			if (mShowBorder) {
				g.lineStyle(0, 0);
				g.drawRect(-w/2, -h/2, w, h);
			}

			if (mClip) {
				if (!mMaskSprite) {
					mMaskSprite = new Sprite();
					addChild(mMaskSprite);
					mRotationWrapper.mask = mMaskSprite;
				}

				var mg:Graphics = mMaskSprite.graphics;
				mg.clear();
				mg.beginFill(0);
				mg.drawRect(-w/2, -h/2, w, h);
			}

			redrawFeatures();
		}

		public function afterTransformUpdated():void
		{
			redrawFeatures(true);
		}

		public function redrawFeatures(id_only:Boolean = false):void
		{
			if (!visible)
				return;

			var f:FGFeature;
			for each(f in mFeatures) {
				if (id_only && !f.independentTransform)
					continue;


				f.redraw(mOwnerMap);
			}

			mPolygonRenderer.startSort();
		}

		public function map(closure:Function):void {
			for each(var f:FGFeature in mFeatures) {
				closure(this, f);
			}
		}
	}
}
