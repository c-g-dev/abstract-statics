package testcore;

typedef Failure = {
    name: String,
    message: String,
    stack: String
}

class RunAllTests {

    static var tests: Array<Test>;

    static function runAllTests() {
        var logger = new TestLogger();
        var failures: Array<Failure> = [];
        for (test in tests) {
            var passed = test.run(logger);
            if (!passed) {
                failures.push({
                    name: test.name,
                    message: test.message,
                    stack: test.stack
                });
            }
        }
        if (failures.length > 0) {
            logger.logTestSuiteFailures(failures);
        }
        else {
            logger.logTestSuitePass();
        }
    }

    //haxe runs __init__ function automatically run before execution
    static function __init__() {
        //read the directory ./cases
        //for each file, use reflection to instantiate the class and call _getAllTests()
        //we will assume that the class madule matches its file name and it extends TestCase
        //add the tests to the tests array
        #if sys
        var dir = Sys.getCwd() + 'src/cases';
        trace(dir);
        tests = [];
        if (sys.FileSystem.exists(dir) && sys.FileSystem.isDirectory(dir)) {
            var files = sys.FileSystem.readDirectory(dir);
            for (f in files) {
                if (StringTools.endsWith(f, '.hx')) {
                    var className = f.substr(0, f.length - 3);
                    var fullClass = 'cases.' + className;
                    
                    var cls = Type.resolveClass(fullClass);
                    if (cls != null) {
                        var instance:TestCase = Type.createInstance(cls, []);
                        var method = Reflect.field(instance, '_getAllTests');

                        if (method != null) {
                            var arr: Array<Test> = cast Reflect.callMethod(instance, method, []);
                            if (arr != null) {
                                for (t in arr) tests.push(t);
                            }
                        }
                    }
                }
            }
        }
        #end
    }

    public static function main() {
        runAllTests();
    }
}