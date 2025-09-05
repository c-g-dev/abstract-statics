package cases;

import EnableAbstractStatic;
import testcore.TestCase;
import testcore.Test;


class EnableAbstractStaticTestCase extends TestCase {
    public function testEnableAbstractStatic(test:Test) {

        var err = Sys.command("cd abstractstaticproj && haxe testcase.hxml");
        test.assert(err == 1, "project should fail to compile");
    }
}
