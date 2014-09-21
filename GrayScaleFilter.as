package com.ishperdysh.controllers.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;
	
	public class GrayScaleFilter extends FragmentFilter
	{
		private static const MIN_COLOR:Vector.<Number> = new <Number>[0, 0, 0, 0.0001];
		private var mShaderProgram:Program3D;
		private var _data:Vector.<Number>;
		
		public function GrayScaleFilter()
		{
			var numPasses : int = 1;
			var resolution : Number = 1.0;
			super(numPasses, resolution);
//			0.2125f, 0.7154f, 0.0721f 
//			color.r * 0.3 + color.g * 0.59 + color.b * 0.11;
			
			_data = new <Number>[0.3,0.59,0.11,1, 0, 0, 0, 1];
		}
		
		public override function dispose():void
		{
			if (mShaderProgram) mShaderProgram.dispose();
			super.dispose();
		}
		
		protected override function createPrograms():void
		{
			trace("asdasdasdasdad")
			var fragmentShader:String =
				"tex ft0, v0,  fs0 <2d, clamp, linear, mipnone>  \n" + // read texture color
				"max ft0, ft0, fc5              \n" + // avoid division through zero in next step
				"div ft0.xyz, ft0.xyz, ft0.www  \n" + // restore original (non-PMA) RGB values
				"mul ft0.xyz, ft0.xyz, fc0.xyz	\n" + //
				"add ft0.x, ft0.x, ft0.y 		\n" +
				"add ft0.x, ft0.x, ft0.z 		\n" +
				"mul ft0.xyz, ft0.xxx, ft0.www  \n" + // multiply with alpha again (PMA)
				"mov oc, ft0                    \n";  // copy to output
			
//			code += "add oc, ft1, fc1\n"; // Move to outup Color regedster
			//			code += "mov oc, ft1"; // Move to outup Color regedster
			mShaderProgram = assembleAgal(fragmentShader);
		}
		
		protected override function activate(pass:int, context:Context3D, texture:Texture):void
		{
			// already set by super class:
			// 
			// vertex constants 0-3: mvpMatrix (3D)
			// vertex attribute 0:   vertex position (FLOAT_2)
			// vertex attribute 1:   texture coordinates (FLOAT_2)
			// texture 0:            input texture
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,_data)
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, MIN_COLOR);
			context.setProgram(mShaderProgram);
		}
	}
}