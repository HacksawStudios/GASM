package gasm.core.systems;
import gasm.core.enums.SystemType;
import gasm.core.System;
import gasm.core.utils.BitIndex;
import gasm.core.utils.Bits;

import gasm.core.enums.ComponentType;

using gasm.core.utils.BitUtils;

/**
 * Updates the actor components.
 * 
 * @author Leo Bergman
 */
class ActorSystem extends System implements ISystem
{
	public function new() 
	{
		type = type.add(SystemType.ACTOR);
		componentFlags = componentFlags.add(ComponentType.Actor);
	}
	
	inline public function update(comp:Component, delta:Float) 
	{	
		if (!comp.inited)
		{		
			comp.init();
			comp.inited = true;
		}
		comp.update(delta);
	}
}