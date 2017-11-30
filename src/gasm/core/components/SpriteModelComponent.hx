package gasm.core.components;
import gasm.core.events.InteractionEvent;
import gasm.core.enums.ComponentType;
import gasm.core.Component;
import gasm.core.enums.InteractionType;

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
    public var visible(default, default):Bool = true;
    public var mask(default, default):Any;
    var _pressHandlers(default, default):Array<InteractionEvent -> Void>;
    var _overHandlers(default, default):Array<InteractionEvent -> Void>;
    var _outHandlers(default, default):Array<InteractionEvent -> Void>;
    var _moveHandlers(default, default):Array<InteractionEvent -> Void>;

    public function new() {
        componentType = ComponentType.GraphicsModel;
        _pressHandlers = [];
        _overHandlers = [];
        _pressHandlers = [];
        _moveHandlers = [];
    }

    override public function dispose() {
        for (type in Type.allEnums(InteractionType)) {
            removeHandlers(type);
        }
    }

    public function addHandler(type:InteractionType, cb:InteractionEvent -> Void) {
        var handlers:Array<InteractionEvent -> Void>;
        switch(type) {
            case PRESS: handlers = _pressHandlers;
            case OVER: handlers = _overHandlers;
            case OUT: handlers = _outHandlers;
            case MOVE: handlers = _moveHandlers;
        }
        handlers.push(cb);
    }

    public function removeHandlers(type:InteractionType) {
        switch(type) {
            case PRESS: _pressHandlers = [];
            case OVER: _overHandlers = [];
            case OUT: _outHandlers = [];
            case MOVE: _moveHandlers = [];
        }
    }

    public function triggerEvent(type:InteractionType, point:{x:Float, y:Float}, owner:Entity) {
        var event = new InteractionEvent(point, owner);
        switch(type) {
            case PRESS: for (handler in _pressHandlers) { handler(event); };
            case OVER: for (handler in _overHandlers) { handler(event); };
            case OUT: for (handler in _outHandlers) { handler(event); };
            case MOVE: for (handler in _moveHandlers) { handler(event); };
        }
    }
}