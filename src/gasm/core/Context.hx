package gasm.core;
import gasm.core.enums.SystemType;


/**
 * ...
 * @author Leo Bergman
 */
interface Context
{
	var baseEntity(get, null):Entity;
	var systems(default, null):Array<ISystem>;
}