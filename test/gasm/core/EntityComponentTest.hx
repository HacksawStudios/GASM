package gasm.core;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
/**
 * Integration tests. Makes sense to test Component end Entity together since we want to properly test traversing the graph.
 * So rather than mocking entities in components and components in entities, we have on test for both.
 */
class EntityComponentTest 
{
	
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	// Entity tests 
	
	
	@Test
	public function childAdded_gettingfirstChild_returnsChild():Void
	{
		var base = new Entity();
		var child = new Entity();
		base.addChild(child);
		Assert.areEqual(child, base.firstChild);
	}
	
	@Test
	public function childAdded_gettingParent_returnsParent():Void
	{
		var base = new Entity();
		var child = new Entity();
		base.addChild(child);
		Assert.areEqual(child.parent, base);
	}
	
	@Test
	public function childrenAdded_gettingfirstChild_returnsFirstChild():Void
	{
		var base = new Entity();
		var child = new Entity();
		var child2 = new Entity();
		base.addChild(child);
		base.addChild(child2);
		Assert.areEqual(child, base.firstChild);
	}
	
	@Test
	public function childrenAdded_gettingNext_returnsSibling():Void
	{
		var base = new Entity();
		var child1 = new Entity();
		base.addChild(child1);
		var child2 = new Entity();
		base.addChild(child2);
		Assert.areEqual(child2, child1.next);
	}
	
	@Test
	public function childrenAdded_gettingParentFirstChild_returnsSibling():Void
	{
		var base = new Entity();
		var child1 = new Entity();
		base.addChild(child1);
		var child2 = new Entity();
		base.addChild(child2);
		Assert.areEqual(child2.parent.firstChild, child1);
	}
	
	
	@Test
	public function componentAdded_gettingFirstComponent_returnsComponent():Void
	{
		var base = new Entity();
		var comp = new TestComponent();
		base.add(comp);
		Assert.areEqual(comp, base.firstComponent);
	}
	
	// Component tests

	@Test
	public function differentComponentsAdded_gettingFirstComponent_returnsFirstComponent():Void
	{
		var base = new Entity();
		// we need to use different classes for different components, since there can only be one of each type.
		var comp1 = new TestComponentA();
		var comp2 = new TestComponentB();
		base.add(comp1);
		base.add(comp2);
		Assert.areEqual(comp1, base.firstComponent);
	}
	
	@Test
	public function sameComponentsAdded_gettingFirstComponent_returnsSecondComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponent();
		var comp2 = new TestComponent();
		base.add(comp1);
		base.add(comp2);
		Assert.areEqual(comp2, base.firstComponent);
	}
	
	/**
	 * We don't want two classes with same super in one Entity, unless Component is super.
	 * So we should use the class which is one step above Component for resolution.
	 */
	@Test
	public function sameBaseComponentsAdded_gettingFirstComponent_returnsSecondComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		var comp2 = new TestComponentExtendsComponentB();
		base.add(comp1);
		base.add(comp2);
		Assert.areEqual(comp2, base.firstComponent);
	}
	
	/**
	 * If we extend classes with different base classes, they should result in en entity with two components.
	 */
	@Test
	public function differentBaseComponentsAdded_gettingFirstComponent_returnsFirstComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsMockA();
		var comp2 = new TestComponentExtendsMockB();
		base.add(comp1);
		base.add(comp2);
		Assert.areEqual(comp1, base.firstComponent);
	}
	
	/**
	 * If we add two components, we should be able to get component B in component A 
	 */
	@Test
	public function componentsAdded_gettingFromFirstOwner_returnsSecondComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentA();
		var comp2 = new TestComponentB();
		base.add(comp1);
		base.add(comp2);
		
		Assert.areEqual(comp2, comp1.owner.get(TestComponentB));
	}
	
	/**
	 * If we add two components with the same base, they should count as same component type, and second component added should replace first.
	 * So when getting comp2 from it's owner, it should get a reference to itself.
	 */
	@Test
	public function sameBaseComponentsAdded_gettingFromSecondOwner_returnsSecondComponent():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		var comp2 = new TestComponentExtendsComponentB();
		base.add(comp1);
		base.add(comp2);
		
		Assert.areEqual(comp2, comp2.owner.get(TestComponentExtendsComponentB));
	}	
	
	/**
	 * While resolution is done from the base class above Component, if you do use a subclass as get argument you have to use the same subclass as was added.
	 */
	@Test
	public function sameBaseComponentsAdded_gettingFromSecondOwnerWithOtherSubclass_returnsNull():Void
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
	@Test
	public function sameBaseComponentsAdded_gettingFromSecondOwner_returnsSecondComponent2():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		var comp2 = new TestComponentExtendsComponentB();
		base.add(comp1);
		base.add(comp2);
		
		Assert.areEqual(comp2, comp2.owner.get(TestComponentExtendsComponentB));
	}	
	
	/**
	 * If we add two components with the same base, we can use the base type to get the component.
	 */
	@Test
	public function sameBaseComponentsAdded_gettingFromSecondOwner_returnsSecondComponent3():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsComponentA();
		base.add(comp1);
		Assert.areEqual(comp1, comp1.owner.get(TestComponent));
	}
	
	/**
	 * If we add two components with the different base, they should count as different component types.
	 * So when getting comp1 from comp2's owner, it should get a reference to comp1.
	 */
	@Test
	public function sameBaseComponentsAdded_gettingFromSecondOwner_returnsSecondComponent4():Void
	{
		var base = new Entity();
		var comp1 = new TestComponentExtendsMockA();
		var comp2 = new TestComponentExtendsMockB();
		base.add(comp1);
		base.add(comp2);
		Assert.areEqual(comp1, comp2.owner.get(TestComponentExtendsMockA));
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