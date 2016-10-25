import utest.Runner;
import utest.ui.Report;

class TestAll {
  public static function main() {
    var runner = new Runner();
    runner.addCase(new gasm.core.EntityComponentTest());
    Report.create(runner);
    runner.run();
  }
  public function new(){}
}