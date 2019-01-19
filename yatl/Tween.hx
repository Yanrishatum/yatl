package yatl;

#if msignal
import msignal.Signal;
#end

/**
 * Basic tweener
 * Is implementation agnostic, hence you need to come up with update system for it yourself.
 */
class Tween
{
  /**
    If above 0, will delay update loop and decrease variable until it reaches 0.
  **/
  public var delay:Float = 0;
  
  private var _duration:Float;
  private var _elapsed:Float;
  private var _t:Float;
  private var _percent:Float;
  
  #if msignal
  /** Fired when start() fuction called and tweener reset/was not running.. */
  public var onStart:Signal1<Tween> = new Signal1();
  /** Fired when tweener finishes. */
  public var onFinish:Signal1<Tween> = new Signal1();
  /** Fired after tweener calls apply(). */
  public var onUpdate:Signal1<Tween> = new Signal1();
  /** Fired when cancel() function called and tweener was not idle. */ 
  public var onCancel:Signal1<Tween> = new Signal1();
  /** Fired when tweener was paused. */
  public var onPause:Signal1<Tween> = new Signal1();
  /** Fired when tweener was unpaused. */
  public var onUnpause:Signal1<Tween> = new Signal1();
  #else
  /** Fired when start() fuction called and tweener reset/was not running.. */
  public dynamic function onStart(t:Tween):Void { }
  /** Fired when tweener finishes. */
  public dynamic function onFinish(t:Tween):Void { }
  /** Fired after tweener calls apply(). */
  public dynamic function onUpdate(t:Tween):Void { }
  /** Fired when cancel() function called and tweener was not idle. */ 
  public dynamic function onCancel(t:Tween):Void { }
  /** Fired when tweener was paused. */
  public dynamic function onPause(t:Tween):Void { }
  /** Fired when tweener was unpaused. */
  public dynamic function onUnpause(t:Tween):Void { }
  #end
  
  /** Returns the progress of the tweener (value between 0..1)*/
  public var percent(get, set):Float;
  private inline function get_percent():Float return _percent;
  private function set_percent(v:Float):Float
  {
    if (v < 0) v = 0;
    else if (v > 1) v = 1;
    _percent = v;
    _elapsed = _duration * v;
    _t = applyEase(v);
    if (state == TweenState.Running)
    {
      apply();
      TweenMacro.emit(onUpdate);
    }
    return v;
  }
  
  /** Returns the progress of the tweener with applied easing function. **/
  public var t(get, never):Float;
  private inline function get_t():Float return _t;
  /** Returns total time elapsed since start. **/
  public var elapsed(get, never):Float;
  private inline function get_elapsed():Float return _elapsed;
  
  /** Easing function applicable to t variable.**/
  public var ease:Float->Float;
  private inline function applyEase(v:Float):Float return ease != null ? ease(v) : v;
  
  /** Current tween state. **/
  public var state(default, null):TweenState;
  
  public var isRunning(get, never):Bool;
  public var isPaused(get, set):Bool;
  private inline function get_isRunning():Bool return state == TweenState.Running;
  private inline function get_isPaused():Bool return state == TweenState.Paused;
  private function set_isPaused(v:Bool):Bool
  {
    if (state == TweenState.Idle) return false;
    else
    {
      var newState:TweenState = v ? TweenState.Paused : TweenState.Running;
      if (newState != state)
      {
        state = newState;
        if (v) TweenMacro.emit(onPause);
        else TweenMacro.emit(onUnpause);
      }
      return v;
    }
  }
  
  // Todo: Reverse
  public var loop:Bool;
  public var reverse:Bool;
  
  public function new(duration:Float = 1, ?ease:Float->Float, loop:Bool = false)
  {
    this.loop = loop;
    this.reverse = false;
    this._elapsed = 0;
    this._duration = duration;
    this.ease = ease;
    this.state = TweenState.Idle;
  }
  
  public function init(?duration:Float, ?ease:Float->Float)
  {
    if (duration != null) this._duration = duration;
    this.ease = ease;
  }
  
  /** Starts the tween if reset == true or state == idle, otherwise resumes tween if it's paused. 
    * Note that it calls apply() and all corresponding callbacks on start. **/
  public function start(reset:Bool = true):Void
  {
    if (reset || (state == TweenState.Idle || state == TweenState.Finished))
    {
      if (reverse)
      {
        _elapsed = _duration;
        _percent = 1;
        _t = applyEase(1);
      }
      else
      {
        _elapsed = 0;
        _percent = 0;
        _t = applyEase(0);
      }
      state = TweenState.Running;
      TweenMacro.emit(onStart);
      apply();
      TweenMacro.emit(onUpdate);
    }
    else if (state == TweenState.Paused) resume();
    
  }
  
  /** Pauses the tween if it's currently running. **/
  public inline function pause():Void
  {
    if (state == TweenState.Running)
    {
      state = TweenState.Paused;
      TweenMacro.emit(onPause);
    }
  }
  
  /** Resumes the tween if it's currently paused. **/
  public inline function resume():Void
  {
    if (state == TweenState.Paused)
    {
      state = TweenState.Running;
      TweenMacro.emit(onUnpause);
    }
  }
  
  /** Update the tween with specified delta-time. **/
  public function update(delta:Float):Bool
  {
    if (state == TweenState.Running)
    {
      if (delay != 0) {
        delay -= delta;
        if (delay <= 0) {
          if (reverse) _elapsed += delay;
          else _elapsed -= delay;
          delay = 0;
        }
        else return false;
      }
      var finished:Bool = 
      if (reverse)
      {
        _elapsed -= delta;
        _elapsed <= 0;
      }
      else 
      {
        _elapsed += delta;
        _elapsed >= _duration;
      }
      
      if (finished)
      {
        if (reverse)
        {
          _elapsed = 0;
          _percent = 0;
          _t = applyEase(0);
        }
        else 
        {
          _elapsed = _duration;
          _percent = 1;
          _t = applyEase(1);
        }
        apply();
        TweenMacro.emit(onUpdate);
        if (!loop) state = TweenState.Finished;
        onTweenFinish();
        TweenMacro.emit(onFinish);
        return true;
      }
      else
      {
        _percent = _elapsed / _duration;
        _t = applyEase(_percent);
        apply();
        TweenMacro.emit(onUpdate);
        return false;
      }
    }
    return false;
  }
  
  /** Cancel the tween if it's paused or running. **/
  public function cancel():Void
  {
    if (state != TweenState.Idle && state != TweenState.Finished)
    {
      state = TweenState.Idle;
      onTweenCancel();
      TweenMacro.emit(onCancel);
    }
  }
  
  public function dispose():Void
  {
    #if msignal
    onStart.removeAll();
    onCancel.removeAll();
    onFinish.removeAll();
    onPause.removeAll();
    onUnpause.removeAll();
    onUpdate.removeAll();
    #end
  }
  
  /** Override this to apply your logic during update tick. **/
  private function apply():Void
  {
    // Actual tweener logic.
  }
  
  /** Called when tween was cancelled. Use it to dispose of the data. **/
  private function onTweenCancel():Void
  {
    
  }
  
  /** Called when tween has been finished. Use it to dispose of the data or do post-tween mumbo-jumbo. **/
  private function onTweenFinish():Void
  {
    
  }
  
}
