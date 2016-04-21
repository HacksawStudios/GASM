package gasm.core.events;
import gasm.core.Entity;

/**
 * ...
 * @author Leo Bergman
 */
class OverEvent
{
	public var pos(default, null): { x:Float, y:Float };
	public var entity:Entity;
	
	public function new(pos:{x:Float, y:Float}, entity:Entity) 
	{
		this.pos = pos;
		this.entity = entity;
	}
}