package;

import haxe.MainLoop;
import haxe.Timer;
import yatl.*;

class Tweentest
{

  private static var _loop:MainEvent;
  private static var _stamp:Float;
  private static var _sprite:Sprite;
  private static var _tween:PosTween;
  
  public static function main()
  {
    _stamp = Timer.stamp();
    _tween = new PosTween();
    _tween.onFinish = function(t) { _loop.stop(); }
    var s:Sprite = _sprite = new Sprite(10, 10);
    _tween.setup(s, 0, 0);
    _loop = MainLoop.add(loop);
  }
  
  private static function loop():Void
  {
    var s:Float = Timer.stamp();
    var delta:Float = s - _stamp;
    _stamp = s;
    _tween.update(delta);
    trace(_sprite.x, _sprite.y);
  }
  
}


class Sprite
{
  public var x:Float;
  public var y:Float;
  public function new(x:Float, y:Float) { this.x = x;this.y = y;}
}

typedef XYObj =
{
  var x:Float;
  var y:Float;
}

@:tween(x)
@:tween(y)
class PosTween extends VariableTween<XYObj> { }