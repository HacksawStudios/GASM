package gasm.system.components;

import gasm.core.enums.ScaleType;
import gasm.core.math.geom.Point;
import gasm.core.components.SpriteModelComponent;
import gasm.core.math.geom.Rectangle;
import gasm.core.enums.ComponentType;
import gasm.core.Component;

class StageScaleComponent extends Component {

    var _originalSpriteRect:Rectangle;
    var _stageSize:Point;
    var _origStageSize:Point;
    var _scaleX:Float = 1.0;
    var _scaleY:Float = 1.0;
    var _width:Float;
    var _height:Float;
    var _spriteModel:SpriteModelComponent;
    var _scaleType:ScaleType;

    public function new(?scaleType:ScaleType) {
        _scaleType = scaleType != null ? scaleType : ScaleType.PROPORTIONAL;
        _originalSpriteRect = {x:0, y:0, w:0, h:0};
        _origStageSize = {x:0, y:0};
        _stageSize = {x:0, y:0};
        componentType = ComponentType.Actor;
    }

    override public function init() {
        _spriteModel = owner.get(SpriteModelComponent);
    }

    override public function update(dt:Float) {
        if(_originalSpriteRect.w <= 0) {
            _originalSpriteRect.x = _spriteModel.x;
            _originalSpriteRect.y = _spriteModel.y;
            _originalSpriteRect.w = _spriteModel.width;
            _originalSpriteRect.h = _spriteModel.height;
        }
        switch(_scaleType) {
            case ScaleType.PROPORTIONAL: scaleProportional();
            case ScaleType.FIT: scaleFit();
        }
    }

    inline function scaleProportional() {
        if(_spriteModel.width > 0) {
            var ratio = 0.0;
            var maxW = _spriteModel.stageSize.x;
            var maxH = _spriteModel.stageSize.y;
            var ratio = Math.min(maxW / _originalSpriteRect.w, maxH / _originalSpriteRect.h);
            if(ratio > 0) {
                _spriteModel.xScale = ratio;
                _spriteModel.yScale = ratio;
            }
        }
    }

    inline function scaleFit() {
        if(_spriteModel.width > 0) {
            var scaleX = _spriteModel.stageSize.x / _originalSpriteRect.w;
            var scaleY = _spriteModel.stageSize.y / _originalSpriteRect.h;
            _spriteModel.xScale = scaleX;
            _spriteModel.yScale = scaleY;
        }

    }
}
