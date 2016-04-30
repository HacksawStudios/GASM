package gasm.core;
import gasm.core.systems.ActorSystem;
import gasm.core.systems.CoreSystem;
import haxe.EnumFlags;
import haxe.Timer;
import gasm.core.enums.ComponentType;
import gasm.core.enums.SystemType;


/**
 * ...
 * @author Leo Bergman
 */

class Engine
{
	public var baseEntity(default, null):Entity;
	var _systems:Array<ISystem>;
	var _lastTime:Float = 0;

	public function new(systems:Array<ISystem>) 
	{
		_systems = systems.concat([new CoreSystem(), new ActorSystem()]);
		_systems.sort(function(x, y) {
			var xval = new EnumFlags<SystemType>();
			xval.set(x.type);
			var yval = new EnumFlags<SystemType>();
			yval.set(y.type);
			if (xval.toInt() > yval.toInt())
			{
				return 1;
			}
			if (xval.toInt() < yval.toInt())
			{
				return -1;
			}
			return 0;
		});
/*		_systems.map(function(system) {
			trace("system:" + system.type.toBinaryString());
			trace("flags:" + system.componentFlags.toBinaryString());
		});*/
		
		_lastTime = Timer.stamp();
		baseEntity = new Entity();
	}
	
	public function tick() 
	{
		var now = Timer.stamp();
		var delta = now - _lastTime;
		updateEntity(baseEntity, delta);
		_lastTime = now;
	}
	
	function updateEntity(entity:Entity, delta:Float) 
	{
        var comp = entity.firstComponent;
        while (comp != null) 
		{
            var next = comp.next;
			for (system in _systems)
			{		
				if(system.componentFlags.has(comp.componentType))
				{
					system.update(comp, delta);
				}
			}
            comp = next;
        }
        var ent = entity.firstChild;
        while (ent != null) 
		{
            var next = ent.next;
            updateEntity(ent, delta);
            ent = next;
        }
	}
}