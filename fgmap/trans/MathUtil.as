package fgmap.trans
{
	import flash.geom.Point;
	public class MathUtil
	{
		public static function cp2(Ax:Number, Ay:Number, Bx:Number, By:Number):Number
		{
			return Ax*By - Bx*Ay;
		}

		public static function resolveVec2(in_out:Point, v1:Point, v2:Point):Boolean
		{
			var m:M22 = new M22();
			m._11 = v1.x;
			m._12 = v2.x;
			m._21 = v1.y;
			m._22 = v2.y;
			m = m.getInvert();
			if (!m) return false;

			var s:Number = in_out.x * m._11 + in_out.y * m._12;
			var t:Number = in_out.x * m._21 + in_out.y * m._22;

			in_out.x = s;
			in_out.y = t;

			return true;
		}
	}
}