package gasm.core.enums;
import gasm.core.utils.BitIndex;

/**
 * Bit flags for different component types.
 * 
 * @author Leo Bergman
 */
@:enum
abstract ComponentType(Int) from UInt to BitIndex
{
	var Model = 1 << 0;
	var ActiveModel = 1 << 1;
    var GraphicsModel = 1 << 2;
	var Graphics3DModel = 1 << 3;
    var TextModel = 1 << 4;
    var SoundModel = 1 << 5;
	var Actor = 1 << 6;
    var Graphics = 1 << 7;
    var Graphics3D = 1 << 8;
    var Text = 1 << 9;
    var Sound = 1 << 10;   
}