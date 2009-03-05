package fgmap
{
	import flash.geom.Point;

	public class GMapCalc
	{
		public static const DEFAULT_TILE_SIZE:int = 256;
		public static var   TILE_SIZE:int         = DEFAULT_TILE_SIZE;
		
		private static function bround(v:Number, min:Number, max:Number):Number
		{
			if (v>max) return max;
			if (v<min) return min;
			return v;
		}
		
		public static function XYtoLatLng(x:Number, y:Number, out:FLatLng):Boolean
		{
			const PI:Number = Math.PI;
			const DPI:Number = PI * 2.0;
			const HPI:Number = PI / 2.0;

			var lng:Number = bround((x-0.5) * DPI, -PI, PI);
			
			var g:Number = (y-0.5) * -DPI;
			var lat:Number = 2.0 * Math.atan( Math.exp(g) ) - HPI;
			
			out.lat = lat;
			out.lng = lng;
			return true;
		}
		
		public static function LatLngToXY(lat:Number, lng:Number, out:Point):Boolean
		{
			const DPI:Number = Math.PI * 2.0;
			const HPI:Number = Math.PI / 2.0;

			var x:Number = lng/DPI + 0.5;

			var s:Number = Math.sin(lat);
			var c:Number = Math.cos(lat);
			var y:Number = Math.log((1+c+s)/(1+c-s)) / -DPI + 0.5;
			
			out.x = x;
			out.y = y;
			
			return true;
		}
		
		public static function calcMapSize(zoom:int):int
		{
			return Math.pow(2, zoom+8);		
		}

		public static function calcMapTileCols(zoom:int):int
		{
			return Math.pow(2, zoom);		
		}
		
		public static function calcTileData(x:Number, y:Number, zoom:int, layer:int):Object
		{
			if (zoom < 0)
				throw "illegal zoom level";

			var mapSize:Number = calcMapSize(zoom);
			var ox:int = Math.floor(x*mapSize) % TILE_SIZE;
			var oy:int = Math.floor(y*mapSize) % TILE_SIZE;
			var tx:int = Math.floor(x*mapSize / TILE_SIZE);
			var ty:int = Math.floor(y*mapSize / TILE_SIZE);

			switch(layer)
			{
			case 0:
				return {tile_index: {x:tx, y:ty}, offset: {x:ox, y:oy}, tile_zoom: (17-zoom)};
			}
	
			throw "illegal layer index";
		}
		
		public static function calcTilePath(tx:int, ty:int, zoom:int):String
		{
			var path:Array  = [];
			var qrts:String = "qrts";

			for (var i:int = 0;i < zoom;i++)
			{
				var t:int = (tx & 1) | ((ty & 1) << 1);
				tx /= 2;
				ty /= 2;
				path.unshift( qrts.charAt(t) );
			}
			path.unshift( 't' );

			return path.join('');
		}
		
		public static function calcMapsZoomIndex(z:int):int
		{
			return 17-z;
		}
	}
}