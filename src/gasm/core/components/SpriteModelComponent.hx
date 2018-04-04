package gasm.core.components;
import gasm.core.math.geom.Point;
import gasm.core.events.InteractionEvent;
import gasm.core.enums.ComponentType;
import gasm.core.Component;
import gasm.core.enums.EventType;

/**
 * Model to interface between different graphics backends.
 * Automatically added when you add ComponentType.GRAPHICS to an Entity.
 * 
 * @author Leo Bergman
 */
class SpriteModelComponent extends Component {
    @:isVar public var x(default, set):Float = 0;
    @:isVar public var y(default, set):Float = 0;
    public var width(get, set):Float;
    public var height(get, set):Float;
    public var xScale(get, set):Float;
    public var yScale(get, set):Float;
    public var origWidth(default, default):Float = -1;
    public var origHeight(default, default):Float = -1;
    public var mouseX(default, default):Float = 0;
    public var mouseY(default, default):Float = 0;
    public var stageMouseX(default, default):Float = 0;
    public var stageMouseY(default, default):Float = 0;
    public var stageSize(default, default):Point = {x:0, y:0};
    public var offsetX(default, default):Float = 0;
    public var offsetY(default, default):Float = 0;
    public var speedX(default, default):Float;
    public var speedY(default, default):Float;
    public var interactive(default, default):Bool = false;
    public var visible(default, default):Bool = true;
    public var mask(default, default):Any;
    public var dirty(default, default):Bool = true;

    var _width:Float = -1;
    var _height:Float = -1;
    var _xScale:Float = 1;
    var _yScale:Float = 1;

    var _pressHandlers(default, default):Array<InteractionEvent -> Void>;
    var _overHandlers(default, default):Array<InteractionEvent -> Void>;
    var _outHandlers(default, default):Array<InteractionEvent -> Void>;
    var _moveHandlers(default, default):Array<InteractionEvent -> Void>;
    var _dragHandlers(default, default):Array<InteractionEvent -> Void>;
    var _downHandlers(default, default):Array<InteractionEvent -> Void>;
    var _upHandlers(default, default):Array<InteractionEvent -> Void>;
    var _resizeHandlers(default, default):Array<InteractionEvent -> Void>;

    public function new() {
        componentType = ComponentType.GraphicsModel;
        _pressHandlers = [];
        _overHandlers = [];
        _outHandlers = [];
        _moveHandlers = [];
        _dragHandlers = [];
        _downHandlers = [];
        _upHandlers = [];
        _resizeHandlers = [];
    }

    override public function dispose() {
        for (type in Type.allEnums(EventType)) {
            removeHandlers(type);
        }
        _pressHandlers = null;
        _overHandlers = null;
        _outHandlers = null;
        _moveHandlers = null;
        _dragHandlers = null;
        _downHandlers = null;
        _upHandlers = null;
        _resizeHandlers = null;
    }

    public function addHandler(type:EventType, cb:InteractionEvent -> Void) {
        var handlers = getHandlers(type);
        handlers.push(cb);
    }

    public function removeHandler(type:EventType, cb:InteractionEvent -> Void) {
        var handlers = getHandlers(type);
        if(handlers != null) {
            for (handler in handlers) {
                if (handler == cb) {
                    handlers.remove(handler);
                }
            }
        }
    }

    public function removeHandlers(type:EventType) {
        var handlers = getHandlers(type);
        handlers = [];
    }

    public function triggerEvent(type:EventType, point:{x:Float, y:Float}, owner:Entity) {
        var event = new InteractionEvent(point, owner);
        var handlers = getHandlers(type);
        for (handler in handlers) {
            handler(event);
        }
    }

    inline function getHandlers(type:EventType):Array<InteractionEvent -> Void> {
        return switch(type) {
            case PRESS: _pressHandlers;
            case OVER: _overHandlers;
            case OUT: _outHandlers;
            case MOVE: _moveHandlers;
            case DRAG: _dragHandlers;
            case DOWN: _downHandlers;
            case UP: _upHandlers;
            case RESIZE: _resizeHandlers;
        }
    }

    public function set_x(val:Float) {
        x = val;
        dirty = true;
        return val;
    }

    public function set_y(val:Float) {
        y = val;
        dirty = true;
        return val;
    }

    public function get_width() {
        return _width;
    }

    public function set_width(val:Float) {
        _width = val;
        if(_width > 0 && origHeight > 0) {
            _xScale = val / origWidth;
        }
        dirty = true;
        return val;
    }

    public function get_height() {
        return _height;
    }

    public function set_height(val:Float) {
        _height = val;
        if(_height > 0 && origHeight > 0) {
            _yScale = val / origHeight;
        }
        dirty = true;
        return val;
    }

    public function get_xScale() {
        return _xScale;
    }

    public function set_xScale(val:Float) {
        _xScale = val;
        if(origWidth > 0) {
            _width = _xScale * origWidth;
        }
        dirty = true;
        return val;
    }

    public function get_yScale() {
        return _yScale;
    }

    public function set_yScale(val:Float) {
        _yScale = val;
        if(origHeight > 0) {
            _height = _yScale * origHeight;
        }
        dirty = true;
        return val;
    }
}