package fgmap.xmap
{
	import flash.display.*;
	import flash.events.*;
	import org.libspark.thread.*;

	public class RollController extends Sprite
	{
		public static const QPI:Number = Math.PI*0.25;
		public static const DPI:Number = Math.PI*2;

		[Embed(source="../res/roll-r.gif")]
		private static const ResetIconClass:Class;

		[Embed(source="../res/roll-cw.gif")]
		private static const CWIconClass:Class;

		[Embed(source="../res/roll-ccw.gif")]
		private static const CCWIconClass:Class;

		private var mBtnReset:RollButton;
		private var mBtnCW:RollButton;
		private var mBtnCCW:RollButton;

		private var mAThread:AnimationThread;

		private var mCurrentAngle:Number = 0;
		private var mAnimationAngle:Number = 0;
		private var mOwner:IRollMap;
		function RollController(o:IRollMap)
		{
			mOwner = o;
			mBtnReset = new RollButton(new ResetIconClass());
			addChild(mBtnReset);
			mBtnReset.x = 26;
			mBtnReset.addEventListener(MouseEvent.CLICK, onResetClick);

			mBtnCW = new RollButton(new CWIconClass());
			addChild(mBtnCW);
			mBtnCW.x = 48;
			mBtnCW.addEventListener(MouseEvent.CLICK, onCWRollClick);
			
			mBtnCCW = new RollButton(new CCWIconClass());
			addChild(mBtnCCW);
			mBtnCCW.x = 0;
			mBtnCCW.addEventListener(MouseEvent.CLICK, onCCWRollClick);

			mAThread = new AnimationThread(this);
			mAThread.start();
		}

		private function onResetClick(e:MouseEvent):void {
			mAnimationAngle = mCurrentAngle;
			mCurrentAngle = 0;

			if (mAnimationAngle > Math.PI)
				mAnimationAngle -= Math.PI*2;

			mAThread.go();
		}

		private function onCCWRollClick(e:MouseEvent):void {
			mAnimationAngle = mCurrentAngle;
			mCurrentAngle -= QPI;
			if (mCurrentAngle < 0.01) {
				mAnimationAngle += DPI;
				mCurrentAngle   += DPI;
			}

			mAThread.go();
		}

		private function onCWRollClick(e:MouseEvent):void {
			mAnimationAngle = mCurrentAngle;
			mCurrentAngle += QPI;
			if (mCurrentAngle >= (DPI-0.01)) {
				mAnimationAngle -= DPI;
				mCurrentAngle   -= DPI;
			}

			mAThread.go();
		}

		public function doAnimation(t:int):void
		{
			saveQuality();

			var s:Number = Math.sin(Number(t) * 0.05 * Math.PI);
			var a:Number = mAnimationAngle * (1.0-s) + mCurrentAngle * s;

			mOwner.mapAngle = a;
		}

		public function finishAnimation():void
		{
			restoreQuality();
		}

		private var mSavedQ:String = null;
		private function saveQuality():void {
			if (!mSavedQ) {
				mSavedQ = stage.quality;
				stage.quality = StageQuality.LOW;
			}
		}

		private function restoreQuality():void {
			if (mSavedQ) {
				stage.quality = mSavedQ;
				mSavedQ = null;
			}
		}
	}
}

class AnimationThread extends org.libspark.thread.Thread
{
	import fgmap.xmap.RollController;
	private var mCtrl:RollController;
	private var mCount:int;

	function AnimationThread(c:RollController)
	{
		mCtrl = c;
	}

	public function go():void
	{
		mCount = 0;
		notify();
	}

	override protected function run():void
	{
		next(tick);
		wait();
	}

	private function tick():void
	{
		mCtrl.doAnimation(++mCount);

		if (mCount >= 10) {
			mCtrl.finishAnimation();
			wait();
		}

		next(tick);
	}
}

class RollButton extends flash.display.SimpleButton
{
	import flash.display.*;

	function RollButton(b:Bitmap)
	{
		upState      = b;
		overState    = b;
		downState    = b;
		hitTestState = b;
		
	}
}
