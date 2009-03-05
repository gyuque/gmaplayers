package fgmap
{
	public class FLatLngAlt extends FLatLng
	{
		public var alt:Number;
		function FLatLngAlt(_lat:Number, _lng:Number, _alt:Number = 0)
		{
			super(_lat, _lng);
			alt = _alt;
		}
	}
}
