import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

#if macro
class EnableForwardStatic {
	static var registry:Map<String, Array<ForwardInfo>> = new Map();

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();

		var ct:ClassType = switch (Context.getLocalType()) {
			case TInst(c, _): c.get();
			default:
				Context.error("@:autoBuild(EnableForwardStatic.auto) can only be applied to classes", Context.currentPos());
		}
		var thisFull = getFullName(ct);

		var declaredHere = collectForwardable(ct, fields);
		if (declaredHere.length > 0) {
			var list = registry.get(thisFull);
			if (list == null)
				list = [];
			for (e in declaredHere) {
				var replaced = false;
				for (i in 0...list.length) {
					if (list[i].name == e.name) {
						list[i] = e;
						replaced = true;
						break;
					}
				}
				if (!replaced)
					list.push(e);
			}
			registry.set(thisFull, list);
		}

		var toAdd = new Array<Field>();
		var existingNames = new Map<String, Bool>();
		for (f in fields)
			existingNames.set(f.name, true);

		var ancestors = getAncestors(ct); 
		var used = new Map<String, Bool>(); 

		for (anc in ancestors) {
			var full = getFullName(anc);
			var entries = registry.get(full);
			if (entries == null)
				continue;
			for (e in entries) {
				if (used.exists(e.name))
					continue;
				used.set(e.name, true);
				if (!existingNames.exists(e.name)) {
					toAdd.push(buildWrapper(e));
				}
			}
		}

		if (toAdd.length > 0)
			fields = fields.concat(toAdd);
		return fields;
	}

	static function collectForwardable(ct:ClassType, fields:Array<Field>):Array<ForwardInfo> {
		var out = new Array<ForwardInfo>();
		var owner = getFullName(ct);

		for (f in fields) {
			if (!hasMeta(f.meta, ":forwardStatic"))
				continue;

			if (!hasAccess(f.access, AStatic)) {
				Context.error("@:forwardStatic can only be applied to static methods", f.pos);
			}
			switch (f.kind) {
				case FFun(fn):
					if (hasAccess(f.access, APrivate)) {
						Context.error("@:forwardStatic method cannot be private (it must be callable from subclasses)", f.pos);
					}
					out.push({
						name: f.name,
						owner: owner,
						params: fn.params,
						args: deepCopyArgs(fn.args),
						ret: fn.ret,
						access: copyAccess(f.access),
						doc: f.doc,
						pos: f.pos
					});
				default:
					Context.error("@:forwardStatic can only be applied to methods", f.pos);
			}
		}
		return out;
	}

	static function buildWrapper(e:ForwardInfo):Field {
		var argsCopy:Array<FunctionArg> = [];
		var callArgs:Array<Expr> = [];
		for (a in e.args) {
			argsCopy.push({
				name: a.name,
				opt: a.opt,
				type: null,
				value: a.value
			});
			callArgs.push(macro $i{a.name});
		}

    var recv:Expr = macro $p{splitPath(e.owner)}
    var methodExpr:Expr = { expr: EField(recv, e.name), pos: e.pos };
    var callExpr:Expr = { expr: ECall(methodExpr, callArgs), pos: e.pos };

		var acc:Array<Access> = [];
		if (hasAccess(e.access, APublic))
			acc.push(APublic);
		if (hasAccess(e.access, AInline))
			acc.push(AInline);
		acc.push(AStatic);

		var meta:Array<MetadataEntry> = [];

		return {
			name: e.name,
			doc: e.doc,
			meta: meta,
			access: acc,
			kind: FFun({
				params: e.params,
				args: argsCopy,
				ret: null,
				expr: macro return $callExpr
			}),
			pos: Context.currentPos()
		};
	}


	static function getFullName(c:ClassType):String {
		return c.pack.concat([c.name]).join(".");
	}

	static function getAncestors(c:ClassType):Array<ClassType> {
		var out:Array<ClassType> = [];
		var sup = c.superClass;
		while (sup != null) {
			var s = sup.t.get();
			out.push(s);
			sup = s.superClass;
		}
		return out;
	}

	static function hasMeta(meta:Array<MetadataEntry>, name:String):Bool {
		if (meta == null)
			return false;
		for (m in meta)
			if (m.name == name)
				return true;
		return false;
	}

	static function hasAccess(acc:Array<Access>, which:Access):Bool {
		if (acc == null)
			return false;
		for (a in acc)
			if (a == which)
				return true;
		return false;
	}

	static function copyAccess(a:Array<Access>):Array<Access> {
		if (a == null)
			return [];
		return [for (x in a) x];
	}

	static function deepCopyArgs(args:Array<FunctionArg>):Array<FunctionArg> {
		if (args == null)
			return [];
		var out = [];
		for (a in args)
			out.push({
				name: a.name,
				opt: a.opt,
				type: a.type,
				value: a.value
			});
		return out;
	}

	static inline function splitPath(s:String):Array<String> {
		return s.split(".");
	}
}

typedef ForwardInfo = {
	var name:String;
	var owner:String;
	var params:Null<Array<TypeParamDecl>>;
	var args:Array<FunctionArg>;
	var ret:ComplexType;
	var access:Array<Access>;
	var doc:Null<String>;
	var pos:Position;
}
#end
