package gasm.core.utils;

/**
 * Intended to be used when setting bit flags for abstract enums.
 * 
 * Instead of typing:
 * var READ = 1 << 0;
 * var WRITE = 1 << 1;
 * var EXECUTE = 1 << 2;
 * 
 * Yuo can use:
 * var READ = new BitIndex(0);
 * var WRITE = new BitIndex(1);
 * var EXECUTE = new BitIndex(2);
 * 
 * This requires the enum type to be BitIndex
 * 
 * Will convert to and from Bits, which is a UInt abstract used to store bit flags.
 * 
 * 
 * @author Leo Bergman
 */
abstract BitIndex(UInt) from UInt to UInt 
{
	inline public function new(val:UInt)
	{
		this = val;
	}
	
	@:from
	public static inline function fromBits(bits:Bits)
	{
		return new BitIndex(1 << bits);
	}
	
	@:to
	public inline function toBits():Bits
	{
		return new Bits(1 << this);
	}
	
}