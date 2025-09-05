
import EnableAbstractStatic;

@:build(EnableAbstractStatic.build())
interface EnableAbstractStaticTestInterface {
    @:abstractStatic public function parse(s:String, ?radix:Int = 10):Int;
}

class EnableAbstractStaticTestClass implements EnableAbstractStaticTestInterface {

    public function new() {
        
    }
}