package fgmap.utils
{
	public class ColorCalc
	{
		public static function darkenColor(c:uint, d:int):uint
		{
			var r:int = (c&0xff0000) >> 16;
			var g:int = (c&0xff00) >> 8;
			var b:int =  c&0xff;

			r -= d; if (r<0) r = 0;
			g -= d; if (g<0) g = 0;
			b -= d; if (b<0) b = 0;

			if (r>255) r = 255;
			if (g>255) g = 255;
			if (b>255) b = 255;

			return (r << 16) | (g << 8) | b;
		}
	}
}