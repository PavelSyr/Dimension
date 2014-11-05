package com.ishperdysh.controllers.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;
	
	public class RotateFilter extends FragmentFilter
	{
		private var startangle : Number = -Math.PI/2
		private static const MIN_COLOR:Vector.<Number> = new <Number>[0, 0, 0, 0.0001];
		private var mShaderProgram:Program3D;
		private var _data:Vector.<Number>;
		private var _scale : Number;
		
		public function RotateFilter()
		{
			var numPasses:int=1;
			var resolution:Number=1.0;
			super(numPasses, resolution);
			var offset : Number = Math.PI / 2;
			_data = Vector.<Number>([
				0.5, // center
				1, // scale
				startangle, // ration
				Math.PI/2 // not used
			]);
		}
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set scale(value:Number):void
		{
			_scale = value;
			_data[9] = _scale
		}
		
		public override function dispose():void
		{
			if (mShaderProgram) mShaderProgram.dispose();
			super.dispose();
		}
		
		protected override function createPrograms():void
		{
			var vertixShader : String = 
				"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
				"mov v0, va1      \n"  // pass texture coordinates to fragment program
			
			var fragmentShader:String =
				"sub ft2.xy, fc0.xx, v0.xy \n"+
				//				
				"mov ft3.z, fc2.w \n"+ // mov angle offset (alpha) to ft3.z
				"cos ft3.x, ft3.z \n"+ // cos(alpha)
				"sin ft3.y, ft3.z \n"+ // sin(alpha)
				// calulate x'
				"mul ft4.x, ft2.x, ft3.x \n" + //x * cos(alpha)
				"mul ft4.y, ft2.y, ft3.y \n" + //y * sin(alpha)
				"sub ft4.z, ft4.x, ft4.y \n" + //ft4.z = x` = x * cos(alpha) - y * sin(alpha)
				// calculate y'
				"mul ft4.x, ft2.x, ft3.y \n" + //x * sin(alpha)
				"mul ft4.y, ft2.y, ft3.x \n" + //y * cos(alpha)
				"add ft4.w, ft4.x, ft4.y \n" + //ft4.w = y` = x * sin(alpha) + y * cos(alpha)
				// adding x0 y0 to x' y'
				"add ft2.xy, ft4.zw, fc2.xx \n" +
				"tex ft0, ft2.xy,  fs0 <2d, clamp, linear, mipnone>  \n" +
				"mov oc, ft0\n";
			mShaderProgram = assembleAgal(fragmentShader,vertixShader);
		}
		
		protected override function activate(pass:int, context:Context3D, texture:Texture):void
		{
			// already set by super class:
			// 
			// vertex constants 0-3: mvpMatrix (3D)
			// vertex attribute 0:   vertex position (FLOAT_2)
			// vertex attribute 1:   texture coordinates (FLOAT_2)
			// texture 0:            input texture
			_data[2] += 0.01;
			if (_data[10] > startangle + Math.PI*2)
				_data[10] = startangle;
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,_data)
			context.setProgram(mShaderProgram);
		}
	}
}