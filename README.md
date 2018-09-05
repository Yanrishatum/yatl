# YATL - Yet Another (Haxe) Tweening Library
Because every Haxe dev should do one at some point.

## Features
* Simple tweening logic with ability to pause.
* Framework agnostic. Wanna tween to update automatically? Ha, nope.
* Macro-powered tweener generator for fast tweening action.
* Callbacks on start/finish/cancel/update/pause/unpause.
* Absolutely no safety checks if the macro-tweened value actually is a float.
* Minimalistic as programmer art, no complex stuff whatsoever.
* Because seriously, I wrote this while VSCode servers were down, and I did not even had Haxe plugin installed.

### The macro tweener
* Use `@:tween` meta on class to declare which fields of the object should be tweened.
```haxe
// This tweener will tween x and y variables and will take any objects that satisfy XYObj typedef.
// You can use only typedefs or classes at the moment (no monomorphs or abstracts).
typedef XYObj =
{
  var x:Float;
  var y:Float;
}

@:tween(x)
@:tween(y)
class PosTween extends VariableTween<XYObj> { }

// ...

var t:PosTween = new PostTween();
// Each VariableTween subclass will get a `setup` function that will take arguments:
// target:T, ...list of tweened values..., [duration:Float], [ease function:Float->Float], [start = true]
// In this caes values are x:Float and y:Float.
t.setup(someSprite, 10, 10, 2, Ease.quintIn);

```

# License
Public domain, because everybody should suffer from flux of tweening libraries.