
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

#if macro
class EnableAbstractStatic {
  public static function build():Array<Field> {
    var fields = Context.getBuildFields();

    var baseCT:ClassType = switch (Context.getLocalType()) {
      case TInst(c, _): c.get();
      default:
        Context.error("@:build(EnableAbstractStatic.build) can only be applied to classes or interfaces", Context.currentPos());
    }

    
    var required = new Array<String>();
    var keptFields = new Array<Field>();
    for (f in fields) {
      if (hasMeta(f.meta, ":abstractStatic")) {
        switch (f.kind) {
          case FFun(_):
            required.push(f.name);
          default:
            Context.error("@:abstractStatic can only be applied to methods", f.pos);
        }
      } else {
        keptFields.push(f);
      }
    }

    if (required.length == 0) return keptFields;

    var baseFullName = getFullName(baseCT);

    Context.onAfterTyping(function(types:Array<ModuleType>) {
      var typedBase:ClassType = null;
      for (t in types) switch (t) {
        case TClassDecl(cRef):
          var cd = cRef.get();
          if (getFullName(cd) == baseFullName) {
            typedBase = cd;
            break;
          }
        default:
      }
      if (typedBase == null) return;

      for (t in types) switch (t) {
        case TClassDecl(cRef):
          var cd = cRef.get();
          if (cd == typedBase) continue;
          if (cd.isInterface) continue;
          if (extendsOrImplements(cd, typedBase)) {
            for (name in required) {
              if (!hasStaticFunction(cd, name)) {
                Context.error("abstract static method \"" + name + "\" from " + baseCT.name + " must be implemented", cd.pos);
              }
            }
          }
        default:
      }
    });
    return keptFields;
  }

  static function hasMeta(meta:Array<MetadataEntry>, name:String):Bool {
    if (meta == null) return false;
    for (m in meta) if (m.name == name) return true;
    return false;
  }

  static function getFullName(c:ClassType):String {
    return c.pack.concat([c.name]).join(".");
  }

  static function extendsOrImplements(c:ClassType, base:ClassType):Bool {
    var sup = c.superClass;
    while (sup != null) {
      var s = sup.t.get();
      if (s == base) return true;
      sup = s.superClass;
    }
    return implementsInterface(c, base);
  }

  static function implementsInterface(c:ClassType, base:ClassType):Bool {
    for (i in c.interfaces) {
      var it = i.t.get();
      if (it.pack.concat([it.name]).join(".") == base.pack.concat([base.name]).join(".")) return true;
      if (implementsInterface(it, base)) return true;
    }
    var sup = c.superClass;
    if (sup != null) {
      if (implementsInterface(sup.t.get(), base)) return true;
    }
    return false;
  }

  static function hasStaticFunction(c:ClassType, name:String):Bool {
    for (f in c.statics.get()) {
      if (f.name == name) {
        switch (f.type) {
          case TFun(_, _): return true;
          default:
        }
      }
    }
    return false;
  }
}
#end