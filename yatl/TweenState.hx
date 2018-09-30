package yatl;

@:enum abstract TweenState(Int)
{
  /** The tween either just created or cancelled. */
  var Idle = 0;
  /** The tween currently paused and can continue. **/
  var Paused = 1;
  /** The tween currently running. **/
  var Running = 2;
  /** Tween finished running. **/
  var Finished = 3;
}
