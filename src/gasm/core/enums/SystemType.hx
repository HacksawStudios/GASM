package gasm.core.enums;
import gasm.core.utils.BitIndex;

/**
 * Bit flags for different system types.
 * 
 * @author Leo Bergman
 */
@:enum abstract SystemType(UInt) from UInt to BitIndex
{
	// Systems will execute according to their index.
    var CORE = 1 << 0;
    var ACTOR = 1 << 1;
    var RENDERING = 1 << 2;
    var RENDERING3D = 1 << 3;
    var SOUND = 1 << 4;
}
 