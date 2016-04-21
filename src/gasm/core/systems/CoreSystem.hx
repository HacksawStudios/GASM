package gasm.core.systems;
import gasm.core.enums.SystemType;
import gasm.core.ISystem;
import gasm.core.utils.Bits;

// Autoremoved by FD if optizing imports
import gasm.core.enums.ComponentType;
using gasm.core.utils.BitUtils;

/**
 * Updates core model compoenents.
 * 
 * @author Leo Bergman
 */
class CoreSystem extends System implements ISystem
{
	public function new() 
	{
		type = type.add(SystemType.CORE);
		componentFlags = componentFlags.add(GraphicsModel).add(TextModel).add(ActiveModel).add(SoundModel);
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