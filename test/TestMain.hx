import buddy.*;
import gasm.core.EntityComponentTest;
import gasm.core.EntityTest;
using buddy.Should;

// Implement "Buddy" and define an array of classes within the brackets:
class TestMain implements Buddy<[
	EntityTest,
    EntityComponentTest
]> {}
