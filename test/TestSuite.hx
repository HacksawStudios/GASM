import massive.munit.TestSuite;

import gasm.core.EntityComponentTest;
import gasm.core.utils.BitIndexTest;
import gasm.core.utils.BitUtilsTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(gasm.core.EntityComponentTest);
		add(gasm.core.utils.BitIndexTest);
		add(gasm.core.utils.BitUtilsTest);
	}
}
