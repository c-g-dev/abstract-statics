# (Haxe) abstract-statics

Abstract static method constraints + Forward static methods to children

The feature that everybody wants but no language ever implements. They will say stuff like "it doesn't make since with the way polymorphism works blah blah blah dogmatist garbage blah blah blah". Well here it is you dumb liars -- simple and easy.

## Installation

```
haxelib install abstract-statics
```

## Usage

### Abstract static methods

```haxe
//force implementation to have static method named parse
@:build(EnableAbstractStatic.build())
interface TestInterface {
    @:abstractStatic 
    public function parse(s:String):Int; //annotate with @:abstractStatic (don't make this method static)
}


class TestImplementationA implements TestInterface {} //compiler error

class TestImplementationB implements TestInterface { 
    public static function parse(s:String):Int { //success
        return Std.parseInt(s);
    }
}
```

### Forward static method to children


```haxe
 //unfortunately need both build and autoBuild
@:build(EnableForwardStatic.build())
@:autoBuild(EnableForwardStatic.build())
class TestParent {
    @:forwardStatic 
    public static function parse(s:String):Int {
        return Std.parseInt(s);
    }
}


class TestChild extends TestParent {}

trace(TestChild.parse("123")); //success!
```