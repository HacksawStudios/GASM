package gasm.system.components;

import gasm.core.enums.ComponentType;
import gasm.core.Entity;
import gasm.core.components.SpriteModelComponent;
import gasm.core.Component;

class PosFollowComponent extends Component {

    var _model:SpriteModelComponent;
    var _followModel:SpriteModelComponent;
    var _followEntity:Entity;

    public function new(followEntity:Entity) {
        componentType = ComponentType.Actor;
        _followEntity = followEntity;
    }

    override public function init() {
        _model = owner.get(SpriteModelComponent);
        _followModel = _followEntity.get(SpriteModelComponent);
        super.init();
    }

    override public function update(dt:Float) {
        _model.x = _followModel.x;
        _model.y = _followModel.y;
    }
}
