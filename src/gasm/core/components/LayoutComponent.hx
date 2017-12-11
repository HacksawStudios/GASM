package gasm.core.components;

import gasm.core.math.geom.Box;
import gasm.core.enums.LayoutType;
import gasm.core.enums.ComponentType;
class LayoutComponent extends Component {
    public var width:Float;
    public var height:Float;

    var _horizontal:LayoutType;
    var _vertical:LayoutType;
    var _layoutComponent:LayoutComponent;
    var _spriteModel:SpriteModelComponent;
    var _margins:Box;

    public function new(horizontal:LayoutType, vertical:LayoutType, ?margins:Box) {
        _horizontal = horizontal;
        _vertical = vertical;
        _margins = margins != null ? margins : {};
        _margins.left = _margins.left != null ? _margins.left : 0;
        _margins.right = _margins.right != null ? _margins.right : 0;
        _margins.top = _margins.top != null ? _margins.top : 0;
        _margins.bottom = _margins.bottom != null ? _margins.bottom : 0;
        componentType = ComponentType.Actor;
    }

    override public function init() {
        _spriteModel = owner.get(SpriteModelComponent);
        _layoutComponent = owner.getFromParents(LayoutComponent);
    }

    override public function update(dt:Float) {
        if (_spriteModel.stageSize.x > 0) {
            width = _spriteModel.stageSize.x - (_margins.left + _margins.right);
            height = _spriteModel.stageSize.y - (_margins.top + _margins.bottom);
            switch(_horizontal) {
                case LEFT: _spriteModel.x = _margins.left;
                case CENTER: _spriteModel.x = (width - _spriteModel.width) / 2;
                case RIGHT: _spriteModel.x = width - (_spriteModel.width + _margins.right);
                default: trace("warn", "Horizontal layout cannot be of type " + _horizontal);
            }
            switch(_vertical) {
                case TOP: _spriteModel.y = _margins.top;
                case MIDDLE: _spriteModel.y = (height - _spriteModel.height) / 2;
                case BOTTOM: _spriteModel.y = height - (_spriteModel.height + _margins.bottom);
                default: trace("warn", "Vertical layout cannot be of type " + _vertical);
            }
        }
    }
}
