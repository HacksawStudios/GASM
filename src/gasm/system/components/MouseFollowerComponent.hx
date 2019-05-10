package gasm.system.components;

import gasm.core.math.geom.Point;
import gasm.core.Component;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;
import gasm.core.math.geom.Coords;

/**
 * ...
 * @author Leo Bergman
 */
class MouseFollowerComponent extends Component {
    var _oldPos:Point;
    var _anchorPosition:AnchorPosition;
    var _offset:Coords;
    var _model:SpriteModelComponent;

    public function new(anchorPosition:AnchorPosition = "center", ?offset:Coords) {
        _offset = (offset == null) ? {x:0, y:0} : offset;
        componentType = ComponentType.Actor;
        _oldPos = {x:0, y:0};
        _anchorPosition = anchorPosition;
    }

    override public function init() {
        _model = owner.get(SpriteModelComponent);
        super.init();
    }

    override public function update(dt:Float) {

        if(_oldPos.x == _model.stageMouseX && _oldPos.y == _model.stageMouseY) {
            return;
        }
        _oldPos.x = _model.stageMouseX;
        _oldPos.y = _model.stageMouseY;
        _model.x = _model.stageMouseX - (_model.width / 2) + _offset.x;
        _model.y = switch (_anchorPosition) {
            case AnchorPosition.TOP: _model.stageMouseY + _offset.y;
            case AnchorPosition.CENTER: _model.stageMouseY - (_model.height / 2) + _offset.y;
            case AnchorPosition.BOTTOM: _model.stageMouseY - _model.height + _offset.y;
        };
    }
}

@:enum abstract AnchorPosition(String) from String to String {
	var TOP = 'top';
	var CENTER = 'center';
	var BOTTOM = 'bottom';
}