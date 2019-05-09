package gasm.system.components;

import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;
import gasm.core.Entity;
import gasm.core.Component;

class ScaleFollowComponent extends Component {
	var _model:SpriteModelComponent;
	var _followModel:SpriteModelComponent;
	var _followEntity:Entity;
	var _multiplier:Float;

	public function new(followEntity:Entity, multiplier:Float = 1.0) {
		componentType = ComponentType.Actor;
		_followEntity = followEntity;
		_multiplier = multiplier;
	}

	override public function init() {
		_model = owner.get(SpriteModelComponent);
		_followModel = _followEntity.get(SpriteModelComponent);
		super.init();
	}

	override public function update(dt:Float) {
		if (_model.xScale != _followModel.xScale * _multiplier) {
			_model.xScale = _followModel.xScale * _multiplier;
		}
		if (_model.yScale != _followModel.yScale * _multiplier) {
			_model.yScale = _followModel.yScale * _multiplier;
		}
	}
}
