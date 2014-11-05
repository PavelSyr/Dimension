package com.ishperdysh.controllers.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;
	
	public class SectorFilter extends FragmentFilter
	{
		private static const MIN_COLOR:Vector.<Number> = new <Number>[0, 0, 0, 0.0001];
		private var mShaderProgram:Program3D;
		private var _data:Vector.<Number>;
		/*private var _vertextData : Vector.<Number>*/
		private var _scale : Number
		
		public function SectorFilter()
		{
			var numPasses:int=1;
			var resolution:Number=1.0;
			super(numPasses, resolution);
			var offset : Number = Math.PI / 2;
			_data = Vector.<Number>([
				1, 
				0, 
				Math.PI, 
				2 * Math.PI,
				
				1e-10, 
				Math.PI / 2, 
				0, // not used
				0, // not used
				
				0.5, // center
				1, // scale
				-Math.PI-0.05, // ration
				Math.PI/2 // angle offset
			]);
			/*_vertextData = new <Number>[0.5,0.5,1,1,
										-0.5,0.5,1,1,
										-0.5,-0.5,1,1,
										0.5,-0.5,1,1];*/
		}
		
		public function get scale():Number
		{
			return _scale;
		}

		public function set scale(value:Number):void
		{
			_scale = value;
			_data[9] = _scale;
			_data[8] = 0.5 * _scale;
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
				
				"sub ft2.xy, fc2.xx, v0.xy \n"+ // x0 - x, y0-y
//				//				
				"mov ft3.z, fc2.w \n"+ // mov angle offset (alpha) to ft3.z
				"neg ft3.z, ft3.z \n"+ // a = -a;
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
				"mov ft2.xy, ft4.zw \n" +
				
				// ft4.x = atan2(ft2.y, ft2.x)  Uses: ft3, ft4, ft5
				"add ft2.x, ft2.x, fc1.x            \n"+ // fudge to prevent div zero
				
				"div ft3.x, ft2.y, ft2.x            \n"+ // ft2.x = ydiff / xdiff
				"neg ft3.y, ft3.x                   \n"+ // ft2.y = -ydiff / xdiff
				
				"mul ft4.y, fc1.y, ft3.x            \n"+ // ft4.x = atan(ft2.x)
				"add ft4.z, fc0.x, ft3.x            \n"+ // atan(x) = Pi / 2 * x / (1 + x)
				"div ft5.x, ft4.y, ft4.z            \n"+
				
				"mul ft4.y, fc1.y, ft3.y            \n"+ // ft4.y = atan(ft2.y)
				"add ft4.z, fc0.x, ft3.y            \n"+ // atan(x) = Pi / 2 * x / (1 + x)
				"div ft5.y, ft4.y, ft4.z            \n"+
//				
				"slt ft4.x, ft2.x, fc0.y            \n"+ // x < 0?  ft4.x=1:0
				"slt ft4.y, ft2.y, fc0.y            \n"+ // y < 0?  ft4.y=1:0
				"sub ft4.z, fc0.x, ft4.x            \n"+ // x >= 0  ft4.z
				"sub ft4.w, fc0.x, ft4.y            \n"+ // y >= 0  ft4.w
////				
				"mul ft3.x, ft4.z, ft4.w            \n"+ // x > 0 && y > 0  ft3.x
				"mul ft3.y, ft4.x, ft4.w            \n"+ // x < 0 && y > 0  ft3.y
				"mul ft3.z, ft4.x, ft4.y            \n"+ // x < 0 && y < 0  ft3.z
				"mul ft3.w, ft4.z, ft4.y            \n"+ // x > 0 && y < 0  ft3.w
//				
				"sub ft4.x, ft5.x, fc0.z            \n"+ // a - Pi  ft4.x
				"neg ft4.y, ft5.y                   \n"+ // -a      ft4.y
				"mov ft4.z, ft5.x                   \n"+ // a       ft4.z
				"sub ft4.w, fc0.z, ft5.y            \n"+ // Pi - a  ft4.w1
				
				"mul ft4, ft4, ft3                  \n"+ // multiply grid of possibilities
//				
				"add ft4.xy, ft4.xz, ft4.yw         \n"+ // add possibilities
				"add ft4.x, ft4.x, ft4.y            \n"+
				
				"tex ft0, v0,  fs0 <2d, clamp, linear, mipnone>  \n" +
				"sge ft2.w, fc2.z, ft4.x \n" + //alpha of segment
				"mov ft0.w, ft2.w\n" + //apply new alpha 
//				"tex ft0, ft2.xy,  fs0 <2d, clamp, linear, mipnone>  \n" +// test rotation
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
			
			_data[10] += 0.05;
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,_data)
			context.setProgram(mShaderProgram);
		}
	}
}