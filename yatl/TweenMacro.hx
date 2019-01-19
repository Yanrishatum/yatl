package yatl;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;

class TweenMacro
{
  public static macro function emit(what:Expr):Expr
  {
    if (Context.defined("msignal"))
    {
      return macro $what.dispatch(this);
    }
    return macro $what(this);
  }
  
  #if macro
  
  private static function buildVariable()
  {
    var cl = Context.getLocalType().getClass();
    var param = cl.superClass.params[0];
    var staticTweener:Bool = cl.meta.extract(":staticTween").length > 0;
    
    var setup:Array<Expr> = [
      macro if (duration != null) this._duration = duration,
      macro this.ease = ease,
      macro this._target = target
    ];
    var apply:Array<Expr> = new Array();
    var fields:Array<Field> = Context.getBuildFields();
    var args:Array<FunctionArg> = [
      { name: "target", type: param.toComplexType() }
    ];
    
    for (meta in cl.meta.extract(":tween"))
    {
      if (meta.params != null && meta.params.length > 0)
      {
        // Todo: Default value for setup()
        // Todo: Custom getter (setup) and setter (apply) code. Different meta?
        // Todo: Allow typedefs
        if (meta.params.length > 1)
        {
          Context.error("@:tween meta: Additional parameters not yet supported", Context.currentPos());
        }
        var fieldName:String = getIdent(meta.params[0]);
        
        var field = findField(param, fieldName, staticTweener);
        if (field == null) Context.error("@:tween meta: Could not find field with name " + fieldName, Context.currentPos());
        if (!field.isPublic) Context.error('@:tween meta: Field $fieldName should be public!', Context.currentPos());
        switch(field.kind)
        {
          case FMethod(_):
            Context.error('@:tween meta: Field $fieldName should be a property or variable!', Context.currentPos());
          case FVar(read, write):
            if (!checkVarReadable(read) || !checkVarReadable(write))
            {
              Context.error('@:tween meta: Field $fieldName should be both readable and writeable from outside! Got: $read $write', Context.currentPos());
            }
        }
        // Todo: Check if I actually can perform math on it.
        
        var fieldType = field.type.toComplexType();
        
        var startName = "_" + fieldName + "_start";
        var moveName = "_" + fieldName + "_move";
        fields.push({
          name: startName, access: [APrivate],
          kind: FVar(fieldType, null),
          pos: Context.currentPos()
        });
        fields.push({
          name: moveName, access: [APrivate],
          kind: FVar(fieldType, null),
          pos: Context.currentPos()
        });
        
        setup.push(macro this.$startName = target.$fieldName);
        setup.push(
          macro this.$moveName = $i{fieldName} - this.$startName
        );
        
        apply.push(macro this._target.$fieldName = this.$startName + this.$moveName * this._t);
        
        args.push( { name: fieldName, type: fieldType } );
      }
      else
      {
        Context.warning("@:tween meta requires at least one field! @:tween(<field>, [custom getter, custom setter])", Context.currentPos());
      }
    }
    
    for (meta in cl.meta.extract(":apply"))
    {
      if (meta.params != null && meta.params.length > 0)
      {
        apply.push(macro var target = this._target);
        for (e in meta.params)
          apply.push(e);
      }
      else 
      {
        Context.warning("@:apply meta requries apply expression!", Context.currentPos());
      }
    }
    
    for (meta in cl.meta.extract(":setup"))
    {
      if (meta.params != null && meta.params.length > 0)
      {
        for (e in meta.params)
          setup.push(e);
      }
      else 
      {
        Context.warning("@:apply meta requries apply expression!", Context.currentPos());
      }
    }
    
    // for (meta in cl.meta.extract(":arg"))
    // {
    //   if (meta.params != null && meta.params > 1)
    //   {
    //     meta.params[1]
    //     // args.push({ name: getIdent(meta.params[0]), })
    //   }
    // }
    
    args.push( { name: "duration", opt: true, type: macro :Float } );
    args.push( { name: "ease", opt: true, type: macro :Float->Float } );
    args.push( { name: "start", opt: true, type: macro :Bool, value: macro true } );
    
    setup.push(macro if (start) this.start(true) );
    
    fields.push({
      name: "setup", access: [APublic],
      kind: FFun({
        args: args,
        expr: macro $b{setup},
        ret: macro :Void
      }),
      pos: Context.currentPos()
    });
    fields.push({
      name: "apply", access: [AOverride, APrivate],
      kind: FFun({
        args: [],
        expr: macro $b{apply},
        ret: macro :Void
      }),
      pos: Context.currentPos()
    });
    
    return fields;
  }
  
  private static function findField(t:Type, name:String, isStatic:Bool):ClassField
  {
    switch(t)
    {
      case TInst(ref, _):
        return ref.get().findField(name, isStatic);
      case TType(ref, pars):
        return findField(ref.get().type, name, isStatic);
      case TAnonymous(ref):
        var anon = ref.get();
        for (f in anon.fields)
        {
          if (f.name == name) return f;
        }
        Context.error('Field $name not found!', Context.currentPos());
        return null;
      default:
        Context.error("Invalid field type", Context.currentPos());
        return null;
    }
  }
  
  private static function getIdent(e:Expr):String
  {
    switch(e.expr)
    {
      case EConst(CIdent(x)), EConst(CString(x)): return x;
      default: Context.error("@:tween: Invalid name field", Context.currentPos());
    }
    return null;
  }
  
  private static function checkVarReadable(kind:VarAccess):Bool
  {
    switch(kind)
    {
      case AccNo, AccNever, AccInline, AccRequire(_, _), AccCtor: return false;
      case AccCall, AccResolve, AccNormal: return true;
    }
  }
  
  #end
}