package testcore;

import testcore.RunAllTests.Failure;

class TestLogger {
    public function new() {}
    public function logTestStart(name: String){
        trace('[START] ' + name);
    }
    public function logTestFailure(name: String, e: Dynamic){
        trace('[FAIL ] ' + name + ' -> ' + Std.string(e));
    }
    public function logTestPass(name: String){
        trace('[PASS ] ' + name);
    }

    public function logTestSuiteFailures(failures:Array<Failure>) {
        var count = failures.length;
        trace('Test suite failed with ' + count + ' failure(s).');
        for (f in failures) {
            trace('     X       - ' + f.name + ': ' + f.message);
        }
    }

    public function logTestSuitePass() {
        trace('All tests passed.');
    }
}