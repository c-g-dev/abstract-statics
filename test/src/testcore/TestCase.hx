package testcore;

@:autoBuild(testcore.TestCaseBuildMacro.build())
abstract class TestCase {

    public function new() {}

    //the intention of this class is that it is extended
    //every method that takes in a single Test argument is a test
    //e.g.
    /*

    class MyTestCase extends TestCase {
        public function testSomething(test: Test) {
            test.assert(true, "This should be true");
        }
        public function testSomethingElse(test: Test) {
            test.assert(false, "This should be false");
        }
    }

    */

    //then the macro will generate a new method that calls _getAllTests()
    //and returns an array of Test objects
    /*
    public function _getAllTests(): Array<Test> {
        return [
            new Test("testSomething", (test) -> {
                test.assert(true, "This should be true");
            }),
            new Test("testSomethingElse", (test) -> {
                test.assert(false, "This should be false");
            }),
        ];
    }
    */

}

