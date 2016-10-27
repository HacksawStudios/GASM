package gasm.core.components;
import gasm.core.enums.ComponentType;
import gasm.core.Component;
import gasm.core.enums.InteractionType;
import gasm.core.events.base.InteractionEvent;

/**
 * Model to interface between different graphics backends.
 * Automatically added when you add ComponentType.GRAPHICS to an Entity.
 * 
 * @author Leo Bergman
 */
class SpriteModelComponent extends Component {
	public var x(default, default):Float = 0;
	public var y(default, default):Float = 0;
	public var width(default, default):Float = -1;
	public var height(default, default):Float = -1;
	public var xScale(default, default):Float = 1;
	public var yScale(default, default):Float = 1;
	public var mouseX(default, default):Float = 0;
	public var mouseY(default, default):Float = 0;
	public var stageMouseX(default, default):Float = 0;
	public var stageMouseY(default, default):Float = 0;
	public var offsetX(default, default):Float = 0;
	public var offsetY(default, default):Float = 0;
	public var speedX(default, default):Float;
	public var speedY(default, default):Float;
	public var interactive(default, default):Bool = false;
	var _pressHandlers(default, default):Array<InteractionEvent -> Void>;
	var _overHandlers(default, default):Array<InteractionEvent -> Void>;
	var _outHandlers(default, default):Array<InteractionEvent -> Void>;
	
	public function new() {
		componentType = ComponentType.GraphicsModel;
	}
	
	public function addHandler(type:InteractionType, cb:InteractionEvent -> Void) {
		var handlers:Array<InteractionEvent -> Void>; 
		switch(type) {
			case PRESS: handlers = _pressHandlers;
			case OVER: handlers = _overHandlers;
			case OUT: handlers = _outHandlers;
		}
		handlers.push(cb);
	}
}