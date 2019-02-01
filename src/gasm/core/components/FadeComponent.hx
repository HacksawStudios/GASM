package gasm.core.components;

import gasm.core.enums.ComponentType;

class FadeComponent extends Component {
	var _config:FadeConfig;
	var _time:Float;
	var _model:SpriteModelComponent;

	public function new(config:FadeConfig) {
		_config = config;
		componentType = ComponentType.Actor;
	}

	override public function init() {
		_model = owner.get(SpriteModelComponent);
		_time = 0.0;
	}

	override public function update(dt:Float) {
		var rate = _time / _config.duration;
		_time += dt;
		if (rate <= 1) {
			_model.alpha = _config.update(rate);
		} else {
			_model.alpha = _config.update(1);
			owner.remove(this);
		}
		super.update(dt);
	}
}

@:structInit
class FadeConfig {
	public var duration:Float;
	public var update:(rate:Float) -> Float;
}
