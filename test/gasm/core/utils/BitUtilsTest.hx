package gasm.core.utils;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;


class BitUtilsTest
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
	public function toBinaryString_withArg0_returns0000():Void
	{
		var str = BitUtils.toBinaryString(0);
		Assert.areEqual("00000000000000000000000000000000", str);
	}
	
	@Test
	public function toBinaryString_withArg8_returns1000():Void
	{
		var str = BitUtils.toBinaryString(8);
		Assert.areEqual("00000000000000000000000000001000", str);
	}
}