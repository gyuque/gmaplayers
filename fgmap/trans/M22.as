package fgmap.trans
{
	public class M22
	{
		public var _11:Number, _12:Number;
		public var _21:Number, _22:Number;

		public static function nearZero(n:Number):Boolean
		{
			return (n > -0.001) && (n < 0.001);
		}

		public function getInvert():M22
		{
			var out:M22 = new M22();
			var det:Number = _11 * _22 - _12 * _21;
			if (nearZero(det))
				return null;
		
			out._11 = _22 / det;
			out._22 = _11 / det;
		
			out._12 = -_12 / det;
			out._21 = -_21 / det;
		
			return out;
		}
	}
}