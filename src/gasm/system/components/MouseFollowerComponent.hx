package gasm.system.components;

import gasm.core.math.geom.Point;
import gasm.core.Component;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;

/**
 * ...
 * @author Leo Bergman
 */
class MouseFollowerComponent extends Component {
    var _oldPos:Point;
    var _model:SpriteModelComponent;

    public function new() {
        componentType = ComponentType.Actor;
        _oldPos = {x:0, y:0};
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
        _model.x = _model.stageMouseX - (_model.width / 2);
        _model.y = _model.stageMouseY - (_model.height / 2);
    }
}