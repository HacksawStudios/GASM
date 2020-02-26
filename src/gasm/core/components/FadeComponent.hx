package gasm.core.components;

import gasm.core.enums.ComponentType;

class FadeComponent extends Component {
	var _config:FadeConfig;
	var _time:Float;
	var _model:SpriteModelComponent;
	var _model3D:ThreeDModelComponent;

	public function new(config:FadeConfig) {
		_config = config;
		componentType = ComponentType.Actor;
	}

	override public function init() {
		_model = owner.get(SpriteModelComponent);
		_model3D = owner.get(ThreeDModelComponent);
		_time = 0.0;
	}

	override public function update(dt:Float) {
		var rate = _time / _config.duration;
		_time += dt;
		if (rate <= 1) {
			var val = _config.update(rate);
			if (_model != null) {
				_model.alpha = val;
			}
			if (_model3D != null) {
				_model3D.alpha = val;
			}
		} else {
			var val = _config.update(1);
			if (_model != null) {
				_model.alpha = val;
			}
			if (_model3D != null) {
				_model3D.alpha = val;
			}
			if (_config.onComplete != null) {
				_config.onComplete();
			}
			remove();
		}

		super.update(dt);
	}
}

@:structInit
class FadeConfig {
	public var duration:Float;
	public var update:(rate:Float) -> Float;
	public var onComplete:Null<() -> Void> = null;
}
