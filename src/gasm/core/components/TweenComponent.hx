package gasm.core.components;

import motion.Actuate;
import gasm.core.components.SpriteModelComponent;
import gasm.core.enums.ComponentType;
import gasm.core.Component;

class TweenComponent extends Component {
    var _properties:Dynamic;
    var _duration:Float;
    var _onComplete:Void -> Void;

    public function new(properties:Dynamic, duration:Float, ?onComplete:Void -> Void) {
        componentType = ComponentType.Actor;
        _properties = properties;
        _onComplete = onComplete;
        _duration = duration;
    }

    override public function init() {
        var model:SpriteModelComponent = owner.get(SpriteModelComponent);
        if (model != null) {
            Actuate.tween(model, _duration, _properties).onComplete(function() {
                if(_onComplete != null){
                    _onComplete();
                }
            });
        } else {
            trace("warn", "Attempting to tween entity without a sprite model. Ensure you have a component with ComponentType.GRAPHICS in the entity you like to tween.");
        }
    }
}