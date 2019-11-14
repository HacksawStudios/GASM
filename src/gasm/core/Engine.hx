package gasm.core;

import haxe.EnumFlags;
import haxe.Timer;
import gasm.core.systems.ActorSystem;
import gasm.core.systems.CoreSystem;
import gasm.core.enums.ComponentType;
import gasm.core.enums.SystemType;
import gasm.core.ISystem;

/**
 * ...
 * @author Leo Bergman
 */
class Engine implements IEngine {
	public var baseEntity(default, null):Entity;
	public var getDelta:Null<() -> Float> = null;

	var _systems:Array<ISystem>;
	var _lastTime:Float = 0;
	var _paused:Bool;

	public function new(systems:Array<ISystem>) {
		systems.push(new CoreSystem());
		systems.push(new ActorSystem());
		systems.sort(function(x, y) {
			var xval = new EnumFlags<SystemType>();
			xval.set(x.type);
			var yval = new EnumFlags<SystemType>();
			yval.set(y.type);
			if (xval.toInt() > yval.toInt()) {
				return 1;
			}
			if (xval.toInt() < yval.toInt()) {
				return -1;
			}
			return 0;
		});
		_systems = systems;
		_lastTime = Timer.stamp();
		baseEntity = new Entity("base");
	}

	public function tick() {
		if (!_paused) {
			var delta = 0.0;
			if (getDelta != null) {
				delta = getDelta();
			} else {
				var now = Timer.stamp();
				delta = now - _lastTime;
				_lastTime = now;
			}
			updateEntity(baseEntity, delta);
		}
	}

	public function pause() {
		_paused = true;
	}

	public function resume() {
		_lastTime = Timer.stamp();
		_paused = false;
	}

	function updateEntity(entity:Entity, delta:Float) {
		for (i in 0..._systems.length) {
			var comp = entity.firstComponent;
			var system = _systems[i];
			while (comp != null) {
				var next = comp.next;
				if (system.componentFlags.has(comp.componentType)) {
					system.update(comp, delta);
				}
				comp = next;
			}
		}
		var ent = entity.firstChild;
		while (ent != null) {
			var next = ent.next;
			updateEntity(ent, delta);
			ent = next;
		}
	}
}
