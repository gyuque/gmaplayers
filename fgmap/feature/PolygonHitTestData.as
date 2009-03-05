package fgmap.feature
{
	public class PolygonHitTestData
	{
		public var faceIndex:int;
		public var hPosition:Number;
		public var alt:Number;

		public function toString():String
		{
			return "Hit: face="+faceIndex;
		}
	}
}
