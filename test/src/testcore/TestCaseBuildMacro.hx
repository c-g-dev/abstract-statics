package testcore;

import haxe.macro.Context;
import haxe.macro.Expr;

class TestCaseBuildMacro {

    public static function build() {
        var fields = Context.getBuildFields();
        var cls = Context.getLocalClass().get();

        var testExprs:Array<Expr> = [];

        for (field in fields) {
            switch (field.kind) {
                case FFun(func):
                    if (func.args != null && func.args.length == 1) {
                        var arg = func.args[0];
                        var isTestParam = false;
                        if (arg.type != null) {
                            switch (arg.type) {
                                case TPath(tp):
                                    var packName = tp.pack.join(".");
                                    if (tp.name == "Test") {
                                        isTestParam = true;
                                    }
                                default:
                            }
                        }
                        if (isTestParam) {
                            var methodName = field.name;
                            var typePath: haxe.macro.TypePath = {
                                pack: cls.pack,
                                name: cls.name
                            };
                            var expr = macro new testcore.Test($v{methodName}, function(test:testcore.Test) {
                                var instance = new $typePath();
                                instance.$methodName(test);
                            });
                            testExprs.push(expr);
                        }
                    }
                default:
            }
        }

        var arrExpr = macro [$a{testExprs}];
        
        var getAllField:Field = {
            name: "_getAllTests",
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro : Array<testcore.Test>,
                expr: macro return $arrExpr
            }),
            pos: Context.currentPos()
        };

        fields.push(getAllField);
        return fields;
    }

}