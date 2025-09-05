package testcore;

class Test {
    public var name: String;
    public var message: String;
    public var stack: String;
    var runnable: Test -> Void;

    public function new(name: String, runnable: Test -> Void) {
        this.name = name;
        this.runnable = runnable;
        this.message = null;
        this.stack = null;
    }
    public function assert(condition: Bool, message: String){
        if (!condition) {
            // fail fast by throwing; runner will catch
            throw message;
        }
    }
    public function run(logger: TestLogger): Bool {
        logger.logTestStart(name);
        try{
            runnable(this);
        } catch (e: Dynamic) {
            logger.logTestFailure(name, e);
            message = Std.string(e);
            stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
            return false;
        }
        logger.logTestPass(name);
        return true;
    }
}