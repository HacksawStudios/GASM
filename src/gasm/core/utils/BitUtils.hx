package gasm.core.utils;

/**
 * Utils to handle bit logic.
 */
class BitUtils
{
    inline public static function add (bits:UInt, mask:Bits):Bits
    {
        return bits | mask;
    }

    inline public static function remove (bits:UInt, mask:Bits):UInt
    {
        return bits & ~mask;
    }

	inline public static function contains (bits:UInt, mask:Bits):Bool
    {
        return bits & mask != 0;
    }
	
	inline public static function toBinaryString(bits:UInt):String
    {
		var str = "";
		var tmp:Int;
		var i:Int = 31;
		while (i >= 0)
		{
			tmp = bits >> i;
			if (tmp & 1 > 0)
			{
				str += "1";
			}
			else
			{
				str += "0";
			}
			i--;
		}
        return str;
    }

    inline public static function toggle (bits:UInt, mask:Bits):UInt
    {
        return bits ^ mask;
    }


    inline public static function containsAll (bits:UInt, mask:Bits):Bool
    {
        return bits & mask == mask;
    }

    public static function set (bits:UInt, mask:Bits, enabled:Bool):UInt
    {
        return enabled ? add(bits, mask) : remove(bits, mask);
    }
}