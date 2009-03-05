package fgmap.trans
{
	public class M44
	{
		public var _11:Number, _12:Number, _13:Number, _14:Number;
		public var _21:Number, _22:Number, _23:Number, _24:Number;
		public var _31:Number, _32:Number, _33:Number, _34:Number;
		public var _41:Number, _42:Number, _43:Number, _44:Number;

		function M44(cpy:M44 = null)
		{
			if (cpy)
				copyFrom(cpy);
			else
				ident();
		}

		public static function fromArray(a:Array):M44
		{
			var m:M44 = new M44();
			m._11 = a[0];  m._12 = a[1];  m._13 = a[2];  m._14 = a[3];
			m._21 = a[4];  m._22 = a[5];  m._23 = a[6];  m._24 = a[7];
			m._31 = a[8];  m._32 = a[9];  m._33 = a[10]; m._34 = a[11];

			return m;
		}

		public function transpose():M44
		{
			var t:Number;

			t = _21; _21 = _12; _12 = t;
			t = _31; _31 = _13; _13 = t;
			t = _41; _41 = _14; _14 = t;

			t = _32; _32 = _23; _23 = t;
			t = _42; _42 = _24; _24 = t;

			t = _43; _43 = _34; _34 = t;

			return this;
		}

		public function get min22():M22
		{
			var m:M22 = new M22();
			m._11 = _11;
			m._12 = _12;
			m._21 = _21;
			m._22 = _22;

			return m;
		}

		public function copyFrom(m:M44):M44
		{
			_11 = m._11;
			_12 = m._12;
			_13 = m._13;
			_14 = m._14;

			_21 = m._21;
			_22 = m._22;
			_23 = m._23;
			_24 = m._24;

			_31 = m._31;
			_32 = m._32;
			_33 = m._33;
			_34 = m._34;

			_41 = m._41;
			_42 = m._42;
			_43 = m._43;
			_44 = m._44;

			return this;
		}

		public function equals(m:M44):Boolean
		{
			return (_11 == m._11) && 
				(_12 == m._12) && 
				(_13 == m._13) && 
				(_14 == m._14) && 

				(_21 == m._21) && 
				(_22 == m._22) && 
				(_23 == m._23) && 
				(_24 == m._24) && 

				(_31 == m._31) && 
				(_32 == m._32) && 
				(_33 == m._33) &&
				(_34 == m._34) && 

				(_41 == m._41) && 
				(_42 == m._42) && 
				(_43 == m._43) &&
				(_44 == m._44);
		}

		public function ident():M44
		{
			      _12 = _13 = _14 = 0;
			_21 =       _23 = _24 = 0;
			_31 = _32 =       _34 = 0;
			_41 = _42 = _43 =       0;

			_11 = _22 = _33 = _44 = 1;

			return this;
		}

		public function transVec3(out:Array, x:Number, y:Number, z:Number):void
		{
			out[0] = x * _11 + y * _21 + z * _31 + _41;
			out[1] = x * _12 + y * _22 + z * _32 + _42;
			out[2] = x * _13 + y * _23 + z * _33 + _43;
		}

		public function transVec3Rot(out:Array, x:Number, y:Number, z:Number):void
		{
			out[0] = x * _11 + y * _21 + z * _31;
			out[1] = x * _12 + y * _22 + z * _32;
			out[2] = x * _13 + y * _23 + z * _33;
		}

		public function mul(A:M44, B:M44):M44
		{

			_11 = A._11*B._11  +  A._12*B._21  +  A._13*B._31  +  A._14*B._41;
			_12 = A._11*B._12  +  A._12*B._22  +  A._13*B._32  +  A._14*B._42;
			_13 = A._11*B._13  +  A._12*B._23  +  A._13*B._33  +  A._14*B._43;
			_14 = A._11*B._14  +  A._12*B._24  +  A._13*B._34  +  A._14*B._44;

			_21 = A._21*B._11  +  A._22*B._21  +  A._23*B._31  +  A._24*B._41;
			_22 = A._21*B._12  +  A._22*B._22  +  A._23*B._32  +  A._24*B._42;
			_23 = A._21*B._13  +  A._22*B._23  +  A._23*B._33  +  A._24*B._43;
			_24 = A._21*B._14  +  A._22*B._24  +  A._23*B._34  +  A._24*B._44;

			_31 = A._31*B._11  +  A._32*B._21  +  A._33*B._31  +  A._34*B._41;
			_32 = A._31*B._12  +  A._32*B._22  +  A._33*B._32  +  A._34*B._42;
			_33 = A._31*B._13  +  A._32*B._23  +  A._33*B._33  +  A._34*B._43;
			_34 = A._31*B._14  +  A._32*B._24  +  A._33*B._34  +  A._34*B._44;

			_41 = A._41*B._11  +  A._42*B._21  +  A._43*B._31  +  A._44*B._41;
			_42 = A._41*B._12  +  A._42*B._22  +  A._43*B._32  +  A._44*B._42;
			_43 = A._41*B._13  +  A._42*B._23  +  A._43*B._33  +  A._44*B._43;
			_44 = A._41*B._14  +  A._42*B._24  +  A._43*B._34  +  A._44*B._44;

			return this;
		}

		public function scaleAll(s:Number):M44
		{
			_11 = _22 = _33 = s;
			_12=_13=_14 = _21=_23=_24 = _31=_32=_34 = _41=_42=_43 = 0;
			_44 = 1;			

			return this;
		}

		public function scaleXYZ(x:Number, y:Number, z:Number):M44
		{
			_11 = x;
			_22 = y;
			_33 = z;
			_12=_13=_14 = _21=_23=_24 = _31=_32=_34 = _41=_42=_43 = 0;
			_44 = 1;			

			return this;
		}

		public function rotX(r:Number):M44
		{
			_22 = Math.cos(r);
			_23 = Math.sin(r);
			_32 = -_23;
			_33 = _22;
	
			_12=_13=_14 = _21=_24 = _31=_34 = _41=_42=_43 = 0;
			_11 = _44 = 1;			

			return this;
		}

		public function rotY(r:Number):M44
		{
			_11 = Math.cos(r);
			_13 = -Math.sin(r);
			_31 = -_13;
			_33 = _11;
	
			_12=_14 = _21=_23=_24 = _32=_34 = _41=_42=_43 = 0;
			_22 = _44 = 1;			

			return this;
		}

		public function rotZ(r:Number):M44
		{
			_11 = Math.cos(r);
			_12 = Math.sin(r);
			_21 = -_12;
			_22 = _11;
	
			_13=_14 = _23=_24 = _31=_32=_34 = _41=_42=_43 = 0;
			_33 = _44 = 1;			

			return this;
		}

	}
}
