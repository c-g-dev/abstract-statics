package cases;

import testcore.TestCase;
import testcore.Test;

class DryRunCase extends TestCase {

    public function testDryRun(test:Test) {
        test.assert(true, "This should be true");
    }
}
