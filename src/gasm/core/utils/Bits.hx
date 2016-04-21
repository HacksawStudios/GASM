package gasm.core.utils;

/**
 * Used to store bit flags.
 * @author Leo Bergman
 */
abstract Bits(UInt) from UInt to UInt
{
	public function new(val:UInt)
	{
		this = val;
	}
	
	@:from 
	public static inline function fromBitIndex(index:BitIndex)
	{
		return new Bits(1 << index);
	}
}