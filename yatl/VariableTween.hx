package yatl;

@:autoBuild(yatl.TweenMacro.buildVariable())
class VariableTween<T> extends Tween
{
  
  private var _target:T;
  
  public var target(get, never):T;
  
  inline function get_target() return _target;
  
  //public function setup<K:T>(target:T, ...fields, ?duration:Float, ?ease:Float->Float):Void
  
  override private function onTweenCancel():Void
  {
    _target = null;
  }
  
  override private function onTweenFinish():Void
  {
    _target = null;
  }
  
}