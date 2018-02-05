package gasm.core.components;

import gasm.core.components.LayoutComponent.Align;
import openfl.display.Shape;
import gasm.core.components.SpriteModelComponent;
import gasm.core.components.LayoutComponent.Align;
import gasm.core.api.singnals.TResize;
import gasm.core.enums.ComponentType;
import gasm.core.enums.EventType;
import gasm.core.enums.ScaleType;
import gasm.core.events.InteractionEvent;
import gasm.core.math.geom.Point;
import gasm.core.math.geom.Rectangle;
import gasm.core.utils.Assert;

class LayoutComponent extends Component {
    public var dirty:Bool = true;

    public var layoutBox(default, null):LayoutBox;
    public var spriteModel(default, null):SpriteModelComponent;
    public var computedMargins(get, null):Margins;

    public function get_computedMargins():Margins {
        return calculateMargins(_margins, _parentLayout);
    }
    public var computedSize(default, null):Float;
    public var isRoot(default, null):Bool;
    public var freeze(default, default):Bool;

    public var originalSpriteRect:Rectangle;
    var _stageSize:Point;
    var _origStageSize:Point;
    var _appModel:AppModelComponent;
    var _margins:Margins;
    var _computedPadding:Size;
    var _lastStageSize:Point;
    var _lastSpriteSize:Point;
    var _lastSpritePos:Point;
    var _displayDelay:Int;
    var _parentBox:LayoutBox;
    var _parentLayout:LayoutComponent;
    var _children:Array<LayoutComponent>;

    public function new(box:LayoutBox, displayDelay:Int = 0) {
        trace("box:" + box);
        if (box.margins == null) {
            box.margins = {};
        }
        if (box.margins.left == null) {
            box.margins.left = {value:0};
        }
        if (box.margins.right == null) {
            box.margins.right = {value:0};
        }
        if (box.margins.top == null) {
            box.margins.top = {value:0};
        }
        if (box.margins.bottom == null) {
            box.margins.bottom = {value:0};
        }
        if (box.dock == null) {
            box.dock = Dock.NONE;
        }
        box.flow = box.flow != null ? box.flow : Flow.HORIZONTAL;
        box.size = box.size != null ? box.size : {value:100, percent:true};
        box.vAlign = box.vAlign != null ? box.vAlign : Align.MID;
        box.hAlign = box.hAlign != null ? box.hAlign : Align.MID;
        layoutBox = box;
        _margins = box.margins;
        _displayDelay = displayDelay;
        originalSpriteRect = {x:0, y:0, w:0, h:0};
        _origStageSize = {x:0, y:0};
        _stageSize = {x:0, y:0};
        _children = [];
        componentType = ComponentType.Actor;
    }

    override public function init() {
        spriteModel = owner.get(SpriteModelComponent);
        Assert.that(spriteModel != null, 'No parent sprite in graph. Cannot use LayoutComponent without a parent.');

        _appModel = owner.getFromParents(AppModelComponent);
        Assert.that(_appModel != null, 'No AppModelComponent in graph. Check that your gasm integration context is adding it.');

        _parentLayout = owner.parent != null ? owner.parent.getFromParents(LayoutComponent) : null;
        if (_parentLayout != null) {
            _parentLayout.addChild(this);
            _parentBox = _parentLayout.layoutBox;
        } else {
            isRoot = true;
        }

        _appModel.resizeSignal.connect(function(size:TResize) {
            layout();
            haxe.Timer.delay(layout, 200);
        });

        spriteModel.addHandler(EventType.RESIZE, onResize);
        _lastStageSize = {x:spriteModel.stageSize.x, y:spriteModel.stageSize.y};
        _lastSpriteSize = {x:spriteModel.width, y:spriteModel.height};
        _lastSpritePos = {x:spriteModel.x, y:spriteModel.y};
        originalSpriteRect = {x: spriteModel.x, y: spriteModel.y, w:spriteModel.width, h:spriteModel.height}
        layout();

        if (_displayDelay > 0) {
            spriteModel.visible = false;
            haxe.Timer.delay(function() {
                spriteModel.visible = true;
            }, _displayDelay);
        }
    }

    public function setSize(w:Float, h:Float) {
        spriteModel.height = h;
        spriteModel.width = w;
    }

    function addChild(child:LayoutComponent) {
        _children.push(child);
    }

    public function layout() {
        if (spriteModel.width > 0) {
            if (originalSpriteRect.w <= 0) {
                originalSpriteRect.x = spriteModel.x;
                originalSpriteRect.y = spriteModel.y;
                originalSpriteRect.w = spriteModel.width;
                originalSpriteRect.h = spriteModel.height;
            }
        } else {
            haxe.Timer.delay(layout, 100);
            return;
        }
        if(freeze) {
            return;
        }
        scale();
    }

    inline function scale() {
        var w = layoutBox.scale != null ? originalSpriteRect.w : spriteModel.width;
        var h = layoutBox.scale != null ? originalSpriteRect.h : spriteModel.height;
        var compartmentWidth:Float;
        var compartmentHeight:Float;
        var margins = calculateMargins(_margins, _parentLayout);
        computedSize = calculateSize(layoutBox.size, _parentLayout);
        calculatePadding();

        var ypos = margins.top.value;
        var xpos = margins.left.value;
        var xMarg = margins.right.value;
        var yMarg = margins.bottom.value;

        var dockedX:Float;
        var dockedY:Float;
        var dockedLeft = getDocked(Dock.LEFT);
        var dockedTop = getDocked(Dock.TOP);
        var dockedRight = getDocked(Dock.RIGHT);
        var dockedBottom = getDocked(Dock.BOTTOM);
        var undocked = getDocked(Dock.NONE);
        var parentSize = getComponentSize(_parentLayout);
        var size = getComponentSize(this);
        for (layoutComp in dockedTop) {
            //layoutComp.layout();
            var childBox = layoutComp.layoutBox;
            var childMargins = layoutComp.computedMargins;
            var xMargins = childMargins.right.value + childMargins.left.value;
            var yMargins = childMargins.top.value + childMargins.bottom.value;
            var targetWidth:Float = w - (xpos + xMarg);
            var targetHeight:Float = layoutComp.spriteModel.height;
            var containerW = size.x - xMargins;
            var containerH = size.y - yMargins;
            layoutComp.spriteModel.origWidth = layoutComp.originalSpriteRect.w;
            layoutComp.spriteModel.origHeight = layoutComp.originalSpriteRect.h;
            switch(layoutComp.layoutBox.scale) {
                case ScaleType.PROPORTIONAL: scaleProportional(containerW, containerH, layoutComp.spriteModel);
                case ScaleType.FIT: scaleFit(containerW, containerH, layoutComp.spriteModel);
                default: layoutComp.setSize(targetWidth, targetHeight);
            }
            var actualWidth = layoutComp.spriteModel.width;
            layoutComp.spriteModel.x = switch(childBox.hAlign) {
                case Align.NEAR: childMargins.left.value;
                case Align.MID: childMargins.left.value + (containerW - actualWidth) / 2;
                case Align.FAR: containerW - (childMargins.right.value + actualWidth);
            }
            var actualHeight = layoutComp.spriteModel.height;
            layoutComp.spriteModel.y = switch(childBox.vAlign) {
                case Align.NEAR: childMargins.top.value;
                case Align.MID: childMargins.top.value + ((size.y - childMargins.bottom.value) - actualHeight) / 2;
                case Align.FAR: containerH - (childMargins.bottom.value + actualHeight);
            }
            ypos += layoutComp.spriteModel.height + _computedPadding.value + yMargins;
        }
        dockedY = ypos;
        for (layoutComp in dockedBottom) {
            var childMargins = layoutComp.computedMargins;
            var childBox = layoutComp.layoutBox;
            var xMargins = childMargins.right.value + childMargins.left.value;
            var yMargins = childMargins.top.value + childMargins.bottom.value;
            var targetWidth:Float = w - (xpos + xMarg);
            var targetHeight:Float = layoutComp.spriteModel.height;
            var containerW = parentSize.x - xMargins;
            var containerH = parentSize.y - yMargins;
            targetWidth -= xMargins;
            targetHeight = containerH = childBox.size.percent ? size.y * (childBox.size.value / 100) : childBox.size.value;
            switch(layoutComp.layoutBox.scale) {
                case ScaleType.PROPORTIONAL: scaleProportional(containerW, containerH, layoutComp.spriteModel);
                case ScaleType.FIT: scaleFit(containerW, containerH, layoutComp.spriteModel);
                default: layoutComp.setSize(targetWidth, targetHeight);
            }
            layoutComp.spriteModel.x = childMargins.left.value;
            layoutComp.spriteModel.y = parentSize.y + childMargins.top.value - (yMarg + layoutComp.spriteModel.height + childMargins.bottom.value);
            yMarg += layoutComp.spriteModel.height + _computedPadding.value;
        }
        for (layoutComp in dockedLeft) {
            var childMargins = layoutComp.computedMargins;
            var childBox = layoutComp.layoutBox;
            var xMargins = childMargins.right.value + childMargins.left.value + xMarg + xpos;
            var yMargins = childMargins.top.value + childMargins.bottom.value + yMarg + ypos;
            var containerW = parentSize.x - xMargins;
            var containerH = parentSize.y - yMargins;
            var targetWidth:Float = w - (xpos + xMarg);
            var targetHeight:Float = layoutComp.spriteModel.height - yMarg;
            targetWidth = containerW = childBox.size.percent ? size.x * (childBox.size.value / 100) : childBox.size.value;
            targetHeight -= yMargins;
            switch(layoutComp.layoutBox.scale) {
                case ScaleType.PROPORTIONAL: scaleProportional(containerW, containerH, layoutComp.spriteModel);
                case ScaleType.FIT: scaleFit(containerW, containerH, layoutComp.spriteModel);
                default: layoutComp.setSize(targetWidth, targetHeight);
            }
            layoutComp.spriteModel.x = xpos + childMargins.left.value;
            layoutComp.spriteModel.y = ypos + childMargins.top.value;
            xpos += layoutComp.spriteModel.width + _computedPadding.value;
        }
        dockedX = xpos;
        for (layoutComp in dockedRight) {
            var childMargins = layoutComp.computedMargins;
            var childBox = layoutComp.layoutBox;
            var xMargins = childMargins.right.value + childMargins.left.value + xMarg + xpos;
            var yMargins = childMargins.top.value + childMargins.bottom.value + yMarg + ypos;
            var containerW = parentSize.x - xMargins;
            var containerH = parentSize.y - yMargins;
            var targetWidth:Float = parentSize.x - (xpos + xMarg);
            var targetHeight:Float = layoutComp.spriteModel.height - yMarg;
            targetWidth = containerW = childBox.size.percent ? size.x * (childBox.size.value / 100) : childBox.size.value;
            targetHeight -= yMargins;
            switch(layoutComp.layoutBox.scale) {
                case ScaleType.PROPORTIONAL: scaleProportional(containerW, containerH, layoutComp.spriteModel);
                case ScaleType.FIT: scaleFit(containerW, containerH, layoutComp.spriteModel);
                default: layoutComp.setSize(targetWidth, targetHeight);
            }
            layoutComp.spriteModel.x = parentSize.x - (xMarg + layoutComp.spriteModel.width + childMargins.right.value);
            layoutComp.spriteModel.y = ypos + childMargins.top.value;
            xMarg += layoutComp.spriteModel.width + _computedPadding.value;
        }
        compartmentWidth = (w - (xpos + xMarg)) / dockedBottom.length;

        xpos = dockedX;
        ypos = dockedY;
        var paddingTotal:Float = (_computedPadding.value * (undocked.length - 1));
        if (layoutBox.flow == Flow.VERTICAL) {
            compartmentWidth = (w - (xpos + xMarg));
            compartmentHeight = (h - (ypos + yMarg + paddingTotal)) / undocked.length;
            for (layoutComp in undocked) {
                /*
                var childMargins = layoutComp.computedMargins;
            var xMargins = childMargins.right.value + childMargins.left.value;
            var yMargins = childMargins.top.value + childMargins.bottom.value;
            var targetWidth:Float = w - (xpos + xMarg);
            var targetHeight:Float = layoutComp.spriteModel.height;
            var containerW = parentSize.x - xMargins;
            var containerH = parentSize.y - yMargins;
            if (layoutComp.computedSize > 0) {
                targetHeight = containerH = layoutComp.computedSize;
            } else {
                targetWidth -= xMargins;
                targetHeight -= yMargins;
            }

            switch(layoutComp.layoutBox.scale) {
                case ScaleType.PROPORTIONAL: scaleProportional(containerW, containerH, layoutComp.spriteModel);
                case ScaleType.FIT: scaleFit(containerW, containerH, layoutComp.spriteModel);
                default: layoutComp.setSize(targetWidth, targetHeight);
            }
            if (layoutBox.flow == Flow.VERTICAL) {
                layoutComp.spriteModel.y = switch(layoutBox.align) {
                    case Align.NEAR: layoutComp.computedMargins.top.value;
                    case Align.MID: layoutComp.computedMargins.top.value + (containerH - layoutComp.spriteModel.height) / 2;
                    case Align.FAR: containerW - (layoutComp.spriteModel.height + childMargins.bottom.value);
                }
                layoutComp.spriteModel.x = childMargins.left.value;
            } else {
                layoutComp.spriteModel.x = switch(layoutBox.align) {
                    case Align.NEAR: layoutComp.computedMargins.left.value;
                    case Align.MID: layoutComp.computedMargins.left.value + (containerW - layoutComp.spriteModel.width) / 2;
                    case Align.FAR: containerH - (layoutComp.spriteModel.width + childMargins.right.value);
                }
                layoutComp.spriteModel.y = childMargins.top.value;
            }
            ypos += layoutComp.spriteModel.height + _computedPadding.value;
                 */
                layoutComp.setSize(w - (xpos + xMarg), compartmentHeight);
                layoutComp.spriteModel.x = xpos + ((compartmentWidth - layoutComp.spriteModel.width) / 2);
                layoutComp.spriteModel.y = switch(layoutBox.vAlign) {
                    case Align.NEAR: ypos + computedMargins.top.value;
                    case Align.MID: Math.max(0, ypos + ((compartmentHeight - layoutComp.spriteModel.height) / 2));
                    case Align.FAR: compartmentHeight - (layoutComp.spriteModel.height + computedMargins.bottom.value);
                };
                ypos += layoutComp.spriteModel.height + _computedPadding.value;
            }
        } else {
            compartmentWidth = (w - (xpos + xMarg + paddingTotal)) / undocked.length;
            compartmentHeight = (h - (ypos + yMarg));
            for (layoutComp in undocked) {
                switch(layoutComp.layoutBox.scale) {
                    case ScaleType.PROPORTIONAL: scaleProportional(compartmentWidth, compartmentHeight, layoutComp.spriteModel);
                    case ScaleType.FIT: scaleFit(compartmentWidth, compartmentHeight, layoutComp.spriteModel);
                }
                layoutComp.spriteModel.x = switch(layoutBox.hAlign) {
                    case Align.NEAR: xpos + layoutComp.computedMargins.left.value;
                    case Align.MID: Math.max(0, xpos + ((compartmentWidth - layoutComp.spriteModel.width) / 2));
                    case Align.FAR: compartmentWidth - (layoutComp.spriteModel.width + layoutComp.computedMargins.right.value);
                };
                layoutComp.spriteModel.y = ypos + ((compartmentHeight - layoutComp.spriteModel.height) / 2);
                xpos += compartmentWidth + _computedPadding.value;
            }
        }
    }
    inline function getDocked(dock:Dock):Array<LayoutComponent> {
        var a:Array<LayoutComponent> = [];
        for (child in _children) {
            if (child.layoutBox.dock == dock) {
                a.push(child);
            }
        }
        return a;
    }

    inline function isDirty():Bool {
        var currStageSize:Point = {x:spriteModel.stageSize.x, y:spriteModel.stageSize.y};
        var currSpriteSize:Point = {x:spriteModel.width, y:spriteModel.height};
        var currSpritePos:Point = {x:spriteModel.x, y:spriteModel.y};
        if (currStageSize.x != _lastStageSize.x || currStageSize.y != _lastStageSize.y
        || currSpriteSize.x != _lastSpriteSize.x || currSpriteSize.y != _lastSpriteSize.y
        || currSpritePos.x != _lastSpritePos.x || currSpritePos.y != _lastSpritePos.y) {
            dirty = true;
            _lastStageSize = currStageSize;
            _lastSpriteSize = currSpriteSize;
            _lastSpritePos = currSpritePos;
        }

        return dirty;
    }

    inline function scaleProportional(containerW:Float, containerH:Float, child:SpriteModelComponent) {
        if (!(containerW > 0) || !(containerH > 0)) {
            return;
        }

/*
        var childW = child.width;
        var childH = child.height;
        if (childW > containerW) {
            childH = childH * (containerW / childW);
            childW = containerW;
            if (childH > containerH) {
                childW = childH * (containerH / childH);
                childH = containerH;
            }
        } else if (childH > containerH) {
            childW = childW * (containerH / childH);
            childH = containerH;
            if (childW > containerW) {
                childH = childH * (containerW / childW);
                childW = containerW;
            }
        }

        child.width = childW;
        child.height = childH;
*/

        // 450 / 300 = 1.5 600 / 300 = 2
        // 450, 450

        var ratio = Math.min(containerW / child.origWidth, containerH / child.origHeight);
        if (ratio > 0) {
            child.height = child.origHeight * ratio;
            child.width = child.origWidth * ratio;
            child.xScale = ratio;
            child.yScale = ratio;

        }
    }

    inline function scaleFit(containerW:Float, containerH:Float, child:SpriteModelComponent) {
        child.xScale = containerW / child.origWidth;
        child.yScale = containerH / child.origHeight;
    }

    inline function calculateSize(size:Size, parent:LayoutComponent):Float {
        var parentSize = getComponentSize(parent);

        var flow = parent != null && parent.layoutBox != null ? parent.layoutBox.flow : Flow.HORIZONTAL;
        var val = 0.0;
        if (size.percent) {
            var parentDim = flow == Flow.VERTICAL ? parentSize.x : parentSize.y;
            val = parentDim * (size.value / 100);
        } else {
            val = size.value;
        }
        return val;
    }

    inline function calculateMargins(margins:Margins, parent:LayoutComponent):Margins {
        var parentSize = getComponentSize(parent);
        return {
            bottom: {value:margins.bottom.percent ? parentSize.y * (margins.bottom.value / 100) : margins.bottom.value},
            top: {value:margins.top.percent ? parentSize.y * (margins.top.value / 100) : margins.top.value},
            left: {value:margins.left.percent ? parentSize.x * (margins.left.value / 100) : margins.left.value},
            right: {value:margins.right.percent ? parentSize.x * (margins.right.value / 100) : margins.right.value},
        };
    }

    inline function getComponentSize(layout:LayoutComponent):Point {
        var w = layout != null && !layout.isRoot ? layout.spriteModel.width : _appModel.stageSize.x;
        var h = layout != null && !layout.isRoot ? layout.spriteModel.height : _appModel.stageSize.y;
        return {x:w, y:h};
    }

    inline function calculatePadding() {
        var value:Float;
        if (layoutBox.padding == null) {
            value = 0;
        } else if (layoutBox.padding.percent) {
            value = layoutBox.size.value * (layoutBox.padding.value / 100);
        } else {
            value = layoutBox.padding.value;
        }
        _computedPadding = {value:value};
    }

    inline function onResize(event:InteractionEvent) {
        layout();
    }
}

typedef LayoutBox = {
?margins:Margins,
?dock:Dock,
?flow:Flow,
?size:Size,
?scale:ScaleType,
?padding:Size,
?vAlign:Align,
?hAlign:Align,
?name:String,
}

typedef Margins = {
?bottom:Size,
?top:Size,
?left:Size,
?right:Size,
}

typedef Size = {
value:Float,
?percent:Bool,
}

/**
* Can be either near, mid or far. If flow is horizontal, near is left and far is right. If flow is vertical, near is top and far is bottom.
**/
enum Align {
    NEAR; MID; FAR;
}

/**
* Defines if the container should be docked in the parent. A child container can be docked either top, bottom, left or right.
* Containers that is not docked (ContainerDock .NONE), as well as display object that are not containers, will be layed out
* according to flow and alignment values of the parent.
**/
enum Dock {
    LEFT; RIGHT; TOP; BOTTOM; NONE;
}

/**
* Flow defines if children of the container should be laid out vertically or horizontally.
**/
enum Flow {
    VERTICAL; HORIZONTAL;
}