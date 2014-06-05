package com.ishperdysh.controllers.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;
	
	public class WaveFilter2 extends FragmentFilter
	{
		private static const FRAGMENT_SHADER:String =
			<![CDATA[
 				mov ft0, v0
				add ft1, v0, fc0.zzzz
				sin ft0.y, ft1.x
//				cos ft0.x, ft0.x
				mul ft0.y, fc0.w, ft0.y
				add ft0.y, ft0.y, v0.y
//				add ft0.y, ft0.y, fc0.y
				tex ft5, ft0.xy, fs0<2d, clamp, linear, nomip>
				mov oc, ft5
			]]>
		
		
		private var mShaderProgram:Program3D;
		private var _data:Vector.<Number> = new <Number>[1, 0.3 , 0.0, 0.2];

		private var n:int = 1;
		public function WaveFilter2(numPasses:int=1, resolution:Number=1.0)
		{
			super(numPasses, resolution);
		}
		
		public override function dispose():void
		{
			if (mShaderProgram) mShaderProgram.dispose();
			super.dispose();
		}
		
		protected override function createPrograms():void
		{
			mShaderProgram = assembleAgal(FRAGMENT_SHADER);
		}
		
		protected override function activate(pass:int, context:Context3D, texture:Texture):void
		{
			// already set by super class:
			// 
			// vertex constants 0-3: mvpMatrix (3D)
			// vertex attribute 0:   vertex position (FLOAT_2)
			// vertex attribute 1:   texture coordinates (FLOAT_2)
			// texture 0:            input texture
			/*if (_data[2] > Math.PI*)
				n=-1;
			if (_data[2] <= 0)
				n = 1*/
			_data[2] +=0.05 * n;
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,_data)
			context.setProgram(mShaderProgram);
		}
	}
}