package 
{
	import flash.utils.setTimeout;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.display.BlendMode;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class Blink extends BaseAnimation
	{
		protected var _blink : Quad
		private var _startAlpha : Number = 0.0;
		private var _endAlpha : Number = 0.7;
		private var _endScale : Number = 3;
		
		public function Blink()
		{
			super();
			_blink = new Quad(15 , 1000,0xFFFFFF);
			_blink.alpha = _startAlpha;
			_blink.rotation = -0.7;
			_blink.blendMode = BlendMode.ADD;
		}
		
		public function show() : void
		{
			_target.addChild(_blink);
			_tween.animate("x",500);
			_tween.animate("alpha",_endAlpha);
			_tween.animate("scaleX",_endScale);
			start();
			
		}
		
		override public function init($target:Object, $time:Number, $transition:Object="linear", $completeCalback:Function=null):void
		{
			_completeCalback = $completeCalback;
			_transition = $transition;
			_time = $time;
			_target = $target;
			Sprite(_target).clipRect = Sprite(_target).getBounds( Sprite(_target));
			if (_tween == null)
				_tween = new Tween(_blink,_time, _transition);
			else
				reset();
			_tween.onComplete = onComplete;
		}
		
		override public function reset() : void
		{
			_tween.reset(_blink, _time, _transition);
			_tween.onComplete = onComplete;
		}
		
		override protected function onComplete () : void
		{
			super.onComplete();
			_target.removeChild(_blink);
			_blink.x = 0;
			_blink.alpha = _startAlpha;
			_blink.scaleX = 1;
			reset();
			setTimeout(show,1000);
		}
	}
}