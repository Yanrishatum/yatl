package yatl;

@:autoBuild(yatl.TweenMacro.buildVariable())
class VariableTween<T> extends Tween
{
  
  private var _target:T;
  
  public var target(get, never):T;
  
  inline function get_target() return _target;
  
  override public function dispose()
  {
    super.dispose();
    _target = null;
  }
  
  //public function setup<K:T>(target:T, ...fields, ?duration:Float, ?ease:Float->Float):Void
  
}