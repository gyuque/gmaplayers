package fgmap
{
	public class FLatLng
	{
		public var lat:Number;
		public var lng:Number;

		function FLatLng(_lat:Number, _lng:Number)
		{
			lat = _lat;
			lng = _lng;
		}

		public function clone():FLatLng
		{
			return new FLatLng(lat, lng);
		}
	}
}
