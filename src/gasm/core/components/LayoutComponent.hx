package gasm.core.components;

import gasm.core.math.geom.Box;
import gasm.core.math.geom.LayoutBox;
import gasm.core.math.geom.Rectangle;
import gasm.core.enums.ScaleType;
import gasm.core.math.geom.Point;
import gasm.core.events.InteractionEvent;
import gasm.core.enums.EventType;
import gasm.core.enums.LayoutType;
import gasm.core.enums.ComponentType;

class LayoutComponent extends Component {
    public var width:Float;
    public var height:Float;
    public var dirty:Bool = true;

    var _originalSpriteRect:Rectangle;
    var _stageSize:Point;
    var _origStageSize:Point;
    var _horizontal:LayoutType;
    var _vertical:LayoutType;
    var _stageScale:ScaleType;
    var _spriteModel:SpriteModelComponent;
    var _margins:LayoutBox;
    var _computedMargins:LayoutBox;
    var _lastStageSize:Point;
    var _lastSpriteSize:Point;
    var _lastSpritePos:Point;
    var _displayDelay:Int;

    public function new(horizontal:LayoutType, vertical:LayoutType, ?stageScale:ScaleType, ?margins:LayoutBox, displayDelay:Int = 0) {
        _horizontal = horizontal;
        _vertical = vertical;

        if(margins == null) {
            margins = {bottom:0, top:0, left:0, right:0};
        }
        _margins = margins;
        _stageScale = stageScale;
        _displayDelay = displayDelay;
        _originalSpriteRect = {x:0, y:0, w:0, h:0};
        _origStageSize = {x:0, y:0};
        _stageSize = {x:0, y:0};
        componentType = ComponentType.Actor;
    }

    override public function init() {
        _spriteModel = owner.get(SpriteModelComponent);
        _spriteModel.addHandler(EventType.RESIZE, resize);
        _lastStageSize = {x:_spriteModel.stageSize.x, y:_spriteModel.stageSize.y};
        _lastSpriteSize = {x:_spriteModel.width, y:_spriteModel.height};
        _lastSpritePos = {x:_spriteModel.x, y:_spriteModel.y};

        while(!isDirty()) {
            resize();
        }
        if(_displayDelay > 0) {
            _spriteModel.visible = false;
            haxe.Timer.delay(function() {
                _spriteModel.visible = true;
            }, _displayDelay);
        }
    }

    function resize(?event:InteractionEvent) {
        calculateMargins();
        if (isDirty()) {
            if (_stageScale != null && _spriteModel.width > 0) {
                if (_originalSpriteRect.w <= 0) {
                    _originalSpriteRect.x = _spriteModel.x;
                    _originalSpriteRect.y = _spriteModel.y;
                    _originalSpriteRect.w = _spriteModel.width;
                    _originalSpriteRect.h = _spriteModel.height;
                }
                switch(_stageScale) {
                    case ScaleType.PROPORTIONAL: scaleProportional();
                    case ScaleType.FIT: scaleFit();
                }
            }
        }

        if (_spriteModel.stageSize.x > 0 && _spriteModel.width > 0) {
            width = _spriteModel.stageSize.x - (_computedMargins.left + _computedMargins.right);
            height = _spriteModel.stageSize.y - (_computedMargins.top + _computedMargins.bottom);
            switch(_horizontal) {
                case LEFT: _spriteModel.x = _computedMargins.left;
                case CENTER: _spriteModel.x = (width - _spriteModel.width) / 2;
                case RIGHT: _spriteModel.x = width - (_spriteModel.width + _computedMargins.right);
                default: trace("warn", "Horizontal layout cannot be of type " + _horizontal);
            }
            switch(_vertical) {
                case TOP: _spriteModel.y = _margins.top;
                case MIDDLE: _spriteModel.y = _computedMargins.top + ((height - _spriteModel.height) / 2);
                case BOTTOM: _spriteModel.y = (_spriteModel.stageSize.y - _computedMargins.bottom) - _spriteModel.height;
                default: trace("warn", "Vertical layout cannot be of type " + _vertical);
            }
        }
    }

    inline function isDirty():Bool {
        var currStageSize = {x:_spriteModel.stageSize.x, y:_spriteModel.stageSize.y};
        var currSpriteSize = {x:_spriteModel.width, y:_spriteModel.height};
        var currSpritePos = {x:_spriteModel.x, y:_spriteModel.y};
        if (currStageSize.x == _lastStageSize.x && currStageSize.y == _lastStageSize.y
        && currSpriteSize.x == _lastSpriteSize.x && currSpriteSize.y == _lastSpriteSize.y
        && currSpritePos.x == _lastSpritePos.x && currSpritePos.y == _lastSpritePos.y) {
            dirty = true;
        }
        _lastStageSize = currStageSize;
        _lastSpriteSize = currSpriteSize;
        _lastSpritePos = currSpritePos;
        return dirty;
    }

    inline function scaleProportional() {
        var ratio = 0.0;
        var maxW = _spriteModel.stageSize.x - (_computedMargins.left + _computedMargins.right);
        var maxH = _spriteModel.stageSize.y - (_computedMargins.top + _computedMargins.bottom);
        var ratio = Math.min(maxW / _originalSpriteRect.w, maxH / _originalSpriteRect.h);
        if (ratio > 0) {
            _spriteModel.xScale = ratio;
            _spriteModel.yScale = ratio;
        }

    }

    inline function scaleFit() {
        var scaleX = _spriteModel.stageSize.x / _originalSpriteRect.w;
        var scaleY = _spriteModel.stageSize.y / _originalSpriteRect.h;
        _spriteModel.xScale = scaleX;
        _spriteModel.yScale = scaleY;
    }

    inline function calculateMargins() {
        if(_margins.percent) {
            _computedMargins = {
                bottom:_spriteModel.stageSize.y * (_margins.bottom / 100),
                top:  _spriteModel.stageSize.y * (_margins.top / 100),
                left: _spriteModel.stageSize.x * (_margins.left / 100),
                right: _spriteModel.stageSize.x * (_margins.right / 100),
            };
        } else {
            _computedMargins = _margins;
        }
        _computedMargins.bottom = Math.isNaN(_computedMargins.bottom) ? 0 : _computedMargins.bottom;
        _computedMargins.top = Math.isNaN(_computedMargins.top) ? 0 : _computedMargins.top;
        _computedMargins.left = Math.isNaN(_computedMargins.left) ? 0 : _computedMargins.left;
        _computedMargins.right = Math.isNaN(_computedMargins.right) ? 0 : _computedMargins.right;

        trace("_computedMargins:" + _computedMargins);
    }
}
