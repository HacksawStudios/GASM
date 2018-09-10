package gasm.core.components;

import gasm.core.math.geom.Point;
import gasm.core.Component;
import gasm.core.components.AppModelComponent;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;

class OffsetComponent extends Component {
	public var offset(default, null):Point;

	var _appModel:AppModelComponent;
	var _scale:Float;

	public function new(?x:Float = 0, ?y:Float = 0, scale = 1.0) {
		offset = {x: x, y: y};
		componentType = ComponentType.Actor;
		_scale = scale;
	}

	override public function init() {
		super.init();
		_appModel = owner.getFromParents(AppModelComponent);
	}

	override public function update(dt:Float) {
		var model:SpriteModelComponent = owner.get(SpriteModelComponent);
		model.offsetX = offset.x * _scale * _appModel.scale;
		model.offsetY = offset.y * _scale * _appModel.scale;
	}
}
