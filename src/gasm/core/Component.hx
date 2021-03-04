package gasm.core;

import gasm.core.enums.ComponentType;

using tink.CoreApi;

/**
 * ...
 * @author Leo Bergman
 */
#if (!macro && !display)
@:autoBuild(gasm.core.macros.ComponentMacros.build())
#end
@:componentAbstract
class Component {
	@:allow(gasm.core)
	public var owner(default, null):Entity = null;

	@:allow(gasm.core)
	public var next(default, null):Component = null;

	// getter will will be completed by build macro in subclasses
	public var name(get, null):String;
	public var baseName(get, null):String;

	public var inited(default, default):Bool = false;

	public var componentType(default, null):ComponentType;
	public var enabled(get, set):Bool;

	var _scheduled:Array<ScheduleItem> = [];
	var _predicates:Array<PredicateItem> = [];

	/**
	 * Called when component been successfully added to entity.
	 * Good place to do general setup, especially if it costly and is done before starting rendering.
	 */
	public function setup() {}

	/**
	 * Called when component is just about to receive its first update.
	 * Good place do things which require the whole Entity/Component graph to be set up, such as initializing things which depends on other components.
	 */
	public function init() {}

	/**
		Assign this to get callback when init is complete and component has had it's first update
	**/
	dynamic public function onAdded() {}

	/**
		Remove this component from eventual owner. Will cause disposal if has an owner, else it is assumed component is already removed and disposed.

		@return True if component had an owner to be removed from
	**/
	public inline function remove():Bool {
		final owned = owner != null;
		if (owned) {
			owner.remove(this);
		}
		return owned;
	}

	/**
	 * Called when component is removed from entity. Called automatically on removal, so prefer using remove function.
	 */
	public function dispose() {
		_scheduled = [];
	}

	/**
	 * Called when this component receives a game tick update.
	 * @param dt Seconds elapsed since last tick.
	 */
	public function update(dt:Float) {
		for (item in _scheduled) {
			item.when -= dt;
			if (item.when <= 0) {
				item.trigger.trigger(Noise);
				_scheduled.remove(item);
			}
		}
		for (item in _predicates) {
			if (item.predicate()) {
				item.trigger.trigger(Noise);
				_predicates.remove(item);
			}
		}
	}

	/**
	 * Schedule a future to be triggered
	 *
	 * NOTE: Depends on implementation calling super.update, which might not be the case with existing components since it was not needed before.
	 *
	 * @param delay Delay in ms after which future should trigger.
	**/
	function after(delay = 0):Future<Noise> {
		final trigger = Future.trigger();
		_scheduled.push({when: (delay / 1000), trigger: trigger});
		return trigger.asFuture();
	}

	/**
		Schedule a future to trigger when a predicate is fulfilled

		@param predicate Function which when returning true will cause future to resolve
		@param timeout Number of seconds to wait for predicate to fultill and else resolve anyway. If unset or 0, future will never time out.
	**/
	function when(predicate:() -> Bool, timeout = 0.0):Future<Noise> {
		final trigger = Future.trigger();
		var remain = timeout;
		var stamp = haxe.Timer.stamp();
		var item:PredicateItem = null;

		final func = timeout > 0 ?() -> {
			final now = haxe.Timer.stamp();
			remain -= now - stamp;
			stamp = now;
			final ready = predicate() || remain <= 0;
			if (ready) {
				_predicates.remove(item);
			} else {
				predicate();
			}
		} : predicate;

		item = {predicate: func, trigger: trigger};
		_predicates.push(item);
		return trigger.asFuture();
	}

	/**
	 * Overridden in subclasses by build macro
	 * @return Name (package + class name)
	 */
	public function get_name():String {
		return null;
	}

	/**
	 * Overridden in subclasses by build macro
	 * @return Name (package + class name)
	 */
	public function get_baseName():String {
		return null;
	}

	/**
	 * Override in subclass
	 * @return True if enabled
	 */
	public function get_enabled():Bool {
		return null;
	}

	/**
	 * Override in subclass
	 * @param val Enable (true) or disable (false)
	 */
	public function set_enabled(val:Bool) {
		return null;
	}
}

typedef ScheduleItem = {
	when:Float,
	trigger:FutureTrigger<Noise>,
}

typedef PredicateItem = {
	predicate:() -> Bool,
	trigger:FutureTrigger<Noise>,
}
