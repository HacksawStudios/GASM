package gasm.core.components;

import tweenxcore.Tools.Easing;
import tweenx909.TweenX;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;
import gasm.core.Component;

class TweenComponent extends Component {
	var _properties:Dynamic;
	var _startProperties:Dynamic;
	var _duration:Float;
	var _spriteModel:SpriteModelComponent;
	var _easing:Float->Float;
	var _completeFunc:Void->Void;

	public function new(properties:Dynamic, duration:Float, startProperties:Dynamic = null, easing:Float->Float = null) {
		componentType = ComponentType.Actor;
		_properties = properties;
		_startProperties = startProperties;
		_duration = duration;
		_easing = easing == null ? Easing.linear : easing;
	}

	override public function init() {
		_spriteModel = owner.get(SpriteModelComponent);
		if (_startProperties != null) {
			for (field in Reflect.fields(_startProperties)) {
				Reflect.setField(_spriteModel, field, Reflect.field(_startProperties, field));
			}
		}
		tween();
	}

	public function onComplete(func:Void->Void) {
		_completeFunc = func;
	}

	inline function tween() {
		if (_spriteModel != null) {
			TweenX.to(_spriteModel, _properties, _duration, _easing).onFinish(function() {
				if (_completeFunc != null) {
					_completeFunc();
				}
				owner.remove(this);
			});
		} else {
			trace("warn",
				"Attempting to tween entity without a sprite model. Ensure you have a component with ComponentType.GRAPHICS in the entity you like to tween.");
		}
	}
}
