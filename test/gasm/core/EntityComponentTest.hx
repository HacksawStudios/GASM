package gasm.core;

import utest.Assert;
import gasm.core.Entity;
import gasm.core.Component;
/**
 * Integration tests. Makes sense to test Component end Entity together since we want to properly test traversing the graph.
 * So rather than mocking entities in components and components in entities, we have on test for both.
 */
class EntityComponentTest 
{
	
	
	public function new() 
	{
		
	}
	
	public function setup():Void
	{
	}
	
	public function teardown():Void
	{
	}
	
	// Entity tests 
	
	
	public function test_childAdded_gettingfirstChild_returnsChild():Void
	{
		var base = new Entity();
		var child = new Entity();
		base.addChild(child);
		Assert.equals(child, base.firstChild);
	}
	
	public function test_childAdded_gettingParent_returnsParent():Void
	{
		var base = new Entity();
		var child = new Entity();
		base.addChild(child);
		Assert.equals(child.parent, base);
	}
	

	public function test_childrenAdded_gettingfirstChild_returnsFirstChild():Void
	{
		var base = new Entity();
		var child = new Entity();
		var child2 = new Entity();
		base.addChild(child);
		base.addChild(child2);
		Assert.equals(child, base.firstChild);
	}
	

	public function test_childrenAdded_gettingNext_returnsSibling():Void
	{
		var base = new Entity();
		var child1 = new Entity();
		base.addChild(child1);
		var child2 = new Entity();
		base.addChild(child2);
		Assert.equals(child2, child1.next);
	}
	

	public function test_childrenAdded_gettingParentFirstChild_returnsSibling():Void
	{
		var base = new Entity();
		var child1 = new Entity();
		base.addChild(child1);
		var child2 = new Entity();
		base.addChild(child2);
		Assert.equals(child2.parent.firstChild, child1);
	}
	
	

	public function test_componentAdded_gettingFirstComponent_returnsComponent():Void
	{
		var base = new Entity();
		var comp = new TestComponent();
		base.add(comp);
		Assert.equals(comp, base.firstComponent);
	}
	
	// Component tests


	public function test_differentComponentsAdded_gettingFirstComponent_returnsFirstComponent():Void
	{
		var base = new Entity();
		// we need to use different classes for different components, since there can only be one of each type.
		var comp1 = new TestComponentA();
		var comp2 = new TestComponentB();
		base.add(comp1);
		base.add(comp2);
		Assert.equals(comp1, base.firstComponent);
	}
	

	public function test_sameComponentsAdded_gettingFirstComponent_returnsSecondComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponent();
		var comp2 = new TestComponent();
		base.add(comp1);
		base.add(comp2);
		Assert.equals(comp2, base.firstComponent);
	}
	
	/**
	 * We don't want two classes with same super in one Entity, unless Component is super.
	 * So we should use the class which is one step above Component for resolution.
	 */

	public function test_sameBaseComponentsAdded_gettingFirstComponent_returnsSecondComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		var comp2 = new TestComponentExtendsComponentB();
		base.add(comp1);
		base.add(comp2);
		Assert.equals(comp2, base.firstComponent);
	}
	
	/**
	 * If we extend classes with different base classes, they should result in en entity with two components.
	 */

	public function test_differentBaseComponentsAdded_gettingFirstComponent_returnsFirstComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsMockA();
		var comp2 = new TestComponentExtendsMockB();
		base.add(comp1);
		base.add(comp2);
		Assert.equals(comp1, base.firstComponent);
	}
	
	/**
	 * If we add two components, we should be able to get component B in component A 
	 */

	public function test_componentsAdded_gettingFromFirstOwner_returnsSecondComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentA();
		var comp2 = new TestComponentB();
		base.add(comp1);
		base.add(comp2);
		
		Assert.equals(comp2, comp1.owner.get(TestComponentB));
	}
	
	/**
	 * If we add two components with the same base, they should count as same component type, and second component added should replace first.
	 * So when getting comp2 from it's owner, it should get a reference to itself.
	 */

	public function test_sameBaseComponentsAdded_gettingFromSecondOwner_returnsSecondComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		var comp2 = new TestComponentExtendsComponentB();
		base.add(comp1);
		base.add(comp2);
		
		Assert.equals(comp2, comp2.owner.get(TestComponentExtendsComponentB));
	}	
	
	/**
	 * While resolution is done from the base class above Component, if you do use a subclass as get argument you have to use the same subclass as was added.
	 */

	public function test_sameBaseComponentsAdded_gettingFromSecondOwnerWithOtherSubclass_returnsNull():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		var comp2 = new TestComponentExtendsComponentB();
		base.add(comp1);
		base.add(comp2);
		
		Assert.isNull(comp2.owner.get(TestComponentExtendsComponentA));
	}	
	
	
	/**
	 * Since base type is used for resolution
	 */

	public function test_sameBaseComponentsAdded_gettingFromSecondOwner_returnsSecondComponent2():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		var comp2 = new TestComponentExtendsComponentB();
		base.add(comp1);
		base.add(comp2);
		
		Assert.equals(comp2, comp2.owner.get(TestComponentExtendsComponentB));
	}	
	
	/**
	 * If we add two components with the same base, we can use the base type to get the component.
	 */

	public function test_sameBaseComponentsAdded_gettingFromSecondOwner_returnsSecondComponent3():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		base.add(comp1);
		Assert.equals(comp1, comp1.owner.get(TestComponent));
	}
	
	/**
	 * If we add two components with the different base, they should count as different component types.
	 * So when getting comp1 from comp2's owner, it should get a reference to comp1.
	 */

	public function test_sameBaseComponentsAdded_gettingFromSecondOwner_returnsSecondComponent4():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsMockA();
		var comp2 = new TestComponentExtendsMockB();
		base.add(comp1);
		base.add(comp2);
		Assert.equals(comp1, comp2.owner.get(TestComponentExtendsMockA));
	}
}

class TestComponent extends Component 
{
	public function new()
	{
		
	}
}

class TestComponentA extends Component 
{
	public function new()
	{
		
	}
}

class TestComponentB extends Component 
{
	public function new()
	{
		
	}
}

class TestComponentExtendsComponentA extends TestComponent
{

}

class TestComponentExtendsComponentB extends TestComponent
{

}

class TestComponentExtendsMockA extends TestComponentA
{

}

class TestComponentExtendsMockB extends TestComponentB
{

}