package com.ishperdysh.utils
{
	import flash.geom.Point;
	import flash.system.Capabilities;

	public class Dimenssion
	{
		public static const DPI_COEFF : Number = 0.394;
		public static const BASE_WIDTH : int = 1024;
		
		private static var _instance : Dimenssion;
		private static var _allow : Boolean = true;
		
		public function get height():Number
		{
			return _height;
		}

		public function get width():Number
		{
			return _width;
		}

		public static function get instance () : Dimenssion
		{
			if (!_instance){
				_allow = false;
				_instance = new Dimenssion();
				_allow = true;
			}
			return _instance;
		}
		
		private var _width : Number;
		private var _height : Number;
		private var _scale : Number;
		private var _dpi : Number;
		private var _minSize:Number;
		
		public function Dimenssion()
		{
			if (_allow == true){
				throw new Error("Singleton Error. Please use Dimenssion.instance");
			}
		}
		
		public function init ($stageWidth : Number, $stageHeight : Number) : void
		{
			if ($stageWidth >= $stageHeight){
				_width = $stageWidth;
				_height = $stageHeight;
			} else {
				_width = $stageHeight;
				_height = $stageWidth;
			}
			_dpi = Capabilities.screenDPI;
			_minSize = _dpi * DPI_COEFF;
			_scale = _width/BASE_WIDTH;
			Log.info("[Dimenssion] init width :", _width, "; height :", _height , "; DPI :" , _dpi, "; sacle :", _scale, "; minSize :" , getMinSize(0));
		}
		
		public function get scale () : Number
		{
			return _scale;
		}
		
		public function getMinSize($a : Number) : Number
		{
			return Math.max($a * scale,_minSize);
		}
		
		/**
		 * @param $a - base value, 
		 * @param $b - value that will be scaled
		 * @return Point()
		 */
		public function getMinSizes($a : Number, $b: Number) : Point
		{
			var mA : Number = getMinSize($a);
			var s : Number = mA / $a;
			return new Point(mA,$b * s);
		}
		
		public function getSize2($value : Number, $direction : String = "width"):Number
		{
			var res : Number = $value * _dpi * DPI_COEFF;
			return Math.min(res,this["_"+$direction]);
		}
	}
}