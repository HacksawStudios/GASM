package gasm.core.components;

import gasm.core.Component;
import gasm.core.enums.ComponentType;
import gasm.core.enums.EventType;
import gasm.core.events.InteractionEvent;
import gasm.core.math.geom.Point;
import gasm.core.math.geom.Vector;

/**
 * Model to interface between different graphics backends.
 * Automatically added when you add ComponentType.Graphics3D to an Entity.
 *
 * @author Leo Bergman
 */
class ThreeDModelComponent extends Component {
	@:isVar public var pos(default, set) = new Vector(0, 0, 0);
	@:isVar public var offset(default, set) = new Vector(0, 0, 0);
	@:isVar public var scale(default, set) = new Vector(1., 1., 1.);
	@:isVar public var dimensions(default, set) = new Vector(0, 0, 0);
	@:isVar public var origDimensions(default, set) = new Vector(0, 0, 0);
	@:isVar public var alpha(default, set) = 1.;
	public var mouseX(default, default) = 0.;
	public var mouseY(default, default) = 0.;
	public var stageMouseX(default, default) = 0.;
	public var stageMouseY(default, default) = 0.;
	public var stageSize(default, default):Point = {x: 0, y: 0};
	public var interactive(default, default) = false;
	public var visible(default, default) = true;
	public var mask(default, default):Any;
	public var dirty(default, default) = false;

	var _pressHandlers(default, default):Array<InteractionEvent->Void>;
	var _overHandlers(default, default):Array<InteractionEvent->Void>;
	var _outHandlers(default, default):Array<InteractionEvent->Void>;
	var _moveHandlers(default, default):Array<InteractionEvent->Void>;
	var _dragHandlers(default, default):Array<InteractionEvent->Void>;
	var _downHandlers(default, default):Array<InteractionEvent->Void>;
	var _upHandlers(default, default):Array<InteractionEvent->Void>;
	var _resizeHandlers(default, default):Array<InteractionEvent->Void>;

	public function new() {
		componentType = ComponentType.Graphics3DModel;
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

	public function addHandler(type:EventType, cb:InteractionEvent->Void) {
		var handlers = getHandlers(type);
		handlers.push(cb);
	}

	public function removeHandler(type:EventType, cb:InteractionEvent->Void) {
		var handlers = getHandlers(type);
		if (handlers != null) {
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

	public function triggerEvent(type:EventType, point:{x:Float, y:Float, ?z:Float}, owner:Entity) {
		var event = new InteractionEvent(point, owner);
		var handlers = getHandlers(type);
		for (handler in handlers) {
			handler(event);
		}
	}

	inline function getHandlers(type:EventType):Array<InteractionEvent->Void> {
		return switch (type) {
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

	public function set_pos(val:Vector) {
		pos = val;
		dirty = true;
		return val;
	}

	public function set_x(val:Float) {
		pos.x = val;
		dirty = true;
		return val;
	}

	public function set_y(val:Float) {
		pos.y = val;
		dirty = true;
		return val;
	}

	public function set_z(val:Float) {
		pos.z = val;
		dirty = true;
		return val;
	}

	public function get_width() {
		return dimensions.x;
	}

	public function set_width(val:Float) {
		dimensions.x = val;
		if (val > 0 && origDimensions.x > 0) {
			scale.x = val / origDimensions.x;
		}
		dirty = true;
		return val;
	}

	public function get_height() {
		return dimensions.y;
	}

	public function set_height(val:Float) {
		dimensions.y = val;
		if (val > 0 && origDimensions.y > 0) {
			scale.y = val / origDimensions.y;
		}
		dirty = true;
		return val;
	}

	public function get_depth() {
		return dimensions.z;
	}

	public function set_depth(val:Float) {
		dimensions.z = val;
		if (dimensions.z > 0 && origDimensions.z > 0) {
			scale.z = val / origDimensions.z;
		}
		dirty = true;
		return val;
	}

	public function get_xScale() {
		return scale.x;
	}

	public function set_xScale(val:Float) {
		scale.x = val;
		if (origDimensions.x > 0) {
			dimensions.x = scale.x * origDimensions.x;
		}
		dirty = true;
		return val;
	}

	public function get_yScale() {
		return scale.y;
	}

	public function set_yScale(val:Float) {
		scale.y = val;
		if (origDimensions.y > 0) {
			dimensions.y = scale.y * origDimensions.y;
		}
		dirty = true;
		return val;
	}

	public function get_zScale() {
		return scale.z;
	}

	public function set_zScale(val:Float) {
		scale.z = val;
		if (origDimensions.z > 0) {
			dimensions.z = scale.z * origDimensions.z;
		}
		dirty = true;
		return val;
	}

	public function set_alpha(val:Float) {
		alpha = val;
		dirty = true;
		return val;
	}

	public function set_dimensions(val:Vector) {
		dimensions = val;
		dirty = true;
		return val;
	}

	public function set_origDimensions(val:Vector) {
		origDimensions = val;
		return val;
	}

	public function set_offset(val:Vector) {
		offset = val;
		dirty = true;
		return val;
	}

	public function set_scale(val:Vector) {
		scale = val;
		dirty = true;
		return val;
	}
}
