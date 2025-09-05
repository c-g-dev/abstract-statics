package cases;

import testcore.TestCase;
import testcore.Test;
import EnableForwardStatic;

@:build(EnableForwardStatic.build())
@:autoBuild(EnableForwardStatic.build())
class ForwardStaticTestObject {
    @:forwardStatic public static function parse(s:String, ?radix:Int = 10):Int {
        return Std.parseInt(s);
    }
}


class Child extends ForwardStaticTestObject {}
class GrandChild extends Child {}


class ForwardStaticTestCase extends TestCase {
    public function testForwardStatic(test:Test) {
        test.assert(ForwardStaticTestObject.parse("123") == 123, "ForwardStaticTestObject.parse should return 123");
        test.assert(Child.parse("123") == 123, "Child.parse should return 123");
        test.assert(GrandChild.parse("123") == 123, "GrandChild.parse should return 123");
    }
}
