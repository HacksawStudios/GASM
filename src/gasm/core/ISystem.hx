package gasm.core;
import gasm.core.enums.SystemType;
import gasm.core.utils.Bits;

/**
 * @author Leo Bergman
 */
interface ISystem 
{
	var type(default, null):Bits ;
	var componentFlags(default, null):Bits;
	function update(comp:Component, delta:Float):Void;
}