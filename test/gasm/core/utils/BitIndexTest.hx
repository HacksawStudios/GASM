package gasm.core.utils;

import massive.munit.Assert;
import massive.munit.async.AsyncFactory;


class BitIndexTest
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
	
	@Test
	public function fromIndex0_toBits_bitsIs1():Void
	{
		var bits:Bits = new BitIndex(0);
		Assert.areEqual(1, bits);
	}
	
	@Test
	public function fromIndex2_toBits_bitsIs4():Void
	{
		var bits:Bits = new BitIndex(2);
		Assert.areEqual(4, bits);
	}
		
	@Test
	public function fromIndex30_toBits_bitsIs1073741824():Void
	{
		var bits:Bits = new BitIndex(30);
		Assert.areEqual(1073741824, bits);
	}
	
	@Test
	public function fromEnum3_toBits_bitsIs8():Void
	{
		var bits:Bits = UIntToBitsEnum.D;
		Assert.areEqual(8, bits);
	}
}

@:enum abstract UIntToBitsEnum(BitIndex) from BitIndex to BitIndex
{
	// Systems will execute according to their provided index.
	// Bit index is the index of the bit in a 32 bit byte, so max 32 systems can be added.
    var A = new BitIndex(0);
    var B = new BitIndex(1);
    var C = new BitIndex(2);
    var D = new BitIndex(3);
    var E = new BitIndex(4);
}
 