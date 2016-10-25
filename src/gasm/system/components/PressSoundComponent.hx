package gasm.system.components;
import gasm.core.components.SoundModelComponent;
import gasm.core.components.SpriteModelComponent;
import gasm.core.events.PressEvent;
import gasm.core.Component;
import gasm.core.enums.ComponentType;

/**
 * ...
 * @author Leo Bergman
 */
class PressSoundComponent extends Component
{
	
	public function new() 
	{
		componentType = ComponentType.Sound;
	}

	override public function init() 
	{
		var spriteModel = owner.get(SpriteModelComponent);
		var soundModel = owner.get(SoundModelComponent);
		spriteModel.pressHandler = function(e:PressEvent)
		{
			soundModel.pos = 0;
			soundModel.playing = true;
		}
	}
}