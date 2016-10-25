package gasm.core;
import buddy.BuddySuite;

using buddy.Should;
/**
 * ...
 * @author Leo Bergman
 */
class EntityTest extends BuddySuite
{
	public function new() 
	{ 
		describe("Entity", {
			describe("addChild", {
				it("should return child as added as firstChild when adding single child", {
					var base = new Entity();
					var child = new Entity();
					base.addChild(child);
					child.should.be(base.firstChild);
				});
				
				it("should return first child added as firstChild when adding two children", {
					var base = new Entity();
					var child = new Entity();
					var child2 = new Entity();
					base.addChild(child);
					base.addChild(child2);
					child.should.be(base.firstChild);
				});
				
				it("should return sibling as next when adding two children", {
					var base = new Entity();
					var child1 = new Entity();
					base.addChild(child1);
					var child2 = new Entity();
					base.addChild(child2);
					child2.should.be(child1.next);
				});
				
				it("should return sibling as parent.firstChild when adding two children", {
					var base = new Entity();
					var child1 = new Entity();
					base.addChild(child1);
					var child2 = new Entity();
					base.addChild(child2);
					child1.should.be(child2.parent.firstChild);		
				});
			});
		});
	}
}