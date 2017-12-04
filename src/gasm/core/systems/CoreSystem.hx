package gasm.core.systems;

import gasm.core.ISystem;
import gasm.core.System;
import gasm.core.enums.SystemType;

/**
 * Updates core model compoenents.
 * 
 * @author Leo Bergman
 */
class CoreSystem extends System implements ISystem {
    public function new() {
        super();
        type = SystemType.CORE;
        componentFlags.set(GraphicsModel);
        componentFlags.set(TextModel);
        componentFlags.set(ActiveModel);
        componentFlags.set(SoundModel);
    }

    inline public function update(comp:Component, delta:Float) {
        if (!comp.inited) {
            comp.init();
            comp.inited = true;
        }
        comp.update(delta);
    }
}