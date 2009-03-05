package
{
	import flash.display.*;
	import flash.text.*;

	public class STDOUT extends Sprite
	{
		private static var theInstance:STDOUT;
		private static var markedTime:Date;
		protected var tx:TextField;

		function STDOUT()
		{
			if (!theInstance)
				theInstance = this;

			tx = new TextField();
			tx.mouseEnabled = false;
			addChild(tx);
		}

		public static function markTime():void
		{
			markedTime = new Date();
		}

		public static function eTime():void
		{
			var t:Date = new Date();
			puts(t.getTime() - markedTime.getTime());
		}

		protected function stdoutFit():void
		{
			tx.width  = width;
			tx.height = height;
		}

		public static function cls():void
		{
			theInstance.tx.text = "";
		}

		public static function puts(s:*):void
		{
			if (s == null)
				theInstance.tx.appendText("(null)\n");
			else
				theInstance.tx.appendText(s +"\n");
		}
	}
}