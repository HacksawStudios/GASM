package gasm.core;

import gasm.core.components.SoundModelComponent;
import gasm.core.components.SpriteModelComponent;
import gasm.core.components.TextModelComponent;
import gasm.core.components.ThreeDModelComponent;
import gasm.core.utils.Assert;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

using Lambda;
using haxe.macro.Tools;

/**
 * A node in the entity hierarchy, and a collection of components.
 *
 * To iterate over the hierarchy, use the parent, firstChild, next and firstComponent fields. For
 * example:
 *
 * ```haxe
 * // Iterate over entity's children
 * var child = entity.firstChild;
 * while (child != null) {
 *     var next = child.next; // Store in case the child is removed in process()
 *     process(child);
 *     child = next;
 * }
 * ```
 */
@:final class Entity {
	/** This entity's parent. */
	public var parent(default, null):Entity = null;

	/** This entity's first child. */
	public var firstChild(default, null):Entity = null;

	/** This entity's next sibling, for iteration. */
	public var next(default, null):Entity = null;

	/** This entity's first component. */
	public var firstComponent(default, null):Component = null;

	private var _compMap:Map<String, Component>;

	public var id(default, null):String;

	public function new(id:String = "") {
		this.id = id;
		_compMap = new Map<String, Component>();
	}

	/**
	 * Add a component to this entity. Any previous component of this type will be replaced.
	 * @returns This instance, for chaining.
	 */
	public function add(component:Component):Entity {
		var baseName = component.baseName;
		Assert.that(_compMap != null, 'Trying to add to disposed entity. $baseName');
		if (component.owner != null) {
			component.owner.remove(component);
		}
		var prev = _compMap.get(baseName);
		if (prev != null) {
			remove(prev);
		}

		_compMap.set(baseName, component);

		var tail = null;
		var comp = firstComponent;

		while (comp != null) {
			tail = comp;
			comp = comp.next;
		}
		if (tail != null) {
			tail.next = component;
		} else {
			firstComponent = component;
		}
		component.owner = this;
		component.next = null;
		Assert.that(component.componentType != null, 'You need to set componentType in contructor of a Component');
		switch component.componentType {
			case Graphics:
				add(new SpriteModelComponent());
			case Text:
				add(new TextModelComponent());
			case Graphics3D:
				add(new ThreeDModelComponent());
			case Sound:
				add(new SoundModelComponent());
			default:
				null;
		}
		component.setup();
		return this;
	}

	/**
	 * Remove a component from this entity.
	 * @return Whether the component was removed.
	 */
	public function remove(component:Component):Bool {
		var prev:Component = null;
		var comp = firstComponent;
		while (comp != null) {
			var next = comp.next;
			if (comp == component) {
				// Splice out the component
				if (prev == null) {
					firstComponent = next;
				} else {
					prev.owner = this;
					prev.next = next;
				}
				if (_compMap != null) {
					_compMap.remove(comp.name);
				}
				if (comp.inited) {
					comp.dispose();
				}
				comp.owner = null;
				comp.next = null;
				return true;
			}
			prev = comp;
			comp = next;
		}
		_compMap = null;
		return false;
	}

	#if (display || dox)
	public function get<T:Component>(componentClass:Class<T>):T {
		return null;
	}
	#else
	macro public function get<T:Component>(self:Expr, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var componentName = macro $componentClass.BASE_NAME;
		#if haxe4
		return macro Std.downcast($self.getComponentByName($componentName), $componentClass);
		#else
		return macro Std.instance($self.getComponentByName($componentName), $componentClass);
		#end
	}
	#end

	#if (display || dox)
	public function getFromParents<T:Component>(componentClass:Class<T>):T {
		return null;
	}
	#else
	macro public function getFromParents<T:Component>(self:Expr, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var name = macro $componentClass.BASE_NAME;
		return macro $self.getFromParentsByName($name, $componentClass);
	}
	#end

	#if (display || dox)
	public function getFromRoot<T:Component>(componentClass:Class<T>):T {
		return null;
	}
	#else
	macro public function getFromRoot<T:Component>(self:Expr, componentClass:ExprOf<Class<T>>):ExprOf<T> {
		var name = macro $componentClass.BASE_NAME;
		return macro $self.getFromRootByName($name, $componentClass);
	}
	#end

	inline public function getComponentByName(name:String):Component {
		return _compMap != null ? _compMap.get(name) : null;
	}

	public function getFromParentsByName<T:Component>(name:String, castToClass:Class<T>):T {
		var entity = this;
		while (entity != null) {
			var component = entity.getComponentByName(name);
			if (component != null) {
				return cast component;
			}
			entity = entity.parent;
		};
		return null;
	}

	public function getFromRootByName<T:Component>(name:String, castToClass:Class<T>):T {
		var component:T = null;
		var retval:T = null;
		var p = this;
		var root = p;
		while (p != null) {
			component = cast p.getComponentByName(name);
			if (component != null) {
				retval = component;
			}
			p = p.parent;
		};
		return cast retval;
	}

	/**
	 * Adds a child to this entity.
	 * @param append Whether to add the entity to the end or beginning of the child list.
	 * @returns This instance, for chaining.
	 */
	public function addChild(entity:Entity, append:Bool = true):Entity {
		if (entity.parent != null) {
			entity.parent.removeChild(entity);
		}
		entity.parent = this;
		if (append) {
			var tail = null;
			var current = firstChild;
			while (current != null) {
				tail = current;
				current = current.next;
			}
			if (tail != null) {
				tail.next = entity;
			} else {
				firstChild = entity;
			}
		} else {
			entity.next = firstChild;
			firstChild = entity;
		}
		return this;
	}

	public function removeChild(entity:Entity) {
		var prev:Entity = null;
		var current = firstChild;
		while (current != null) {
			var next = current.next;
			if (current == entity) {
				if (prev == null) {
					firstChild = next;
				} else {
					prev.next = next;
				}
				current.parent = null;
				current.next = null;
				current.dispose();
				return;
			}
			prev = current;
			current = next;
		}
	}

	/**
	 * Dispose all of this entity's children, without touching its own components or removing itself
	 * from its parent.
	 */
	public function disposeChildren() {
		while (firstChild != null) {
			var nextChild = firstChild.next;
			firstChild.dispose();
			firstChild = nextChild;
		}
	}

	/**
	 * Removes this entity from its parent, and disposes all its components and children.
	 */
	public function dispose() {
		if (parent != null) {
			parent.removeChild(this);
			parent = null;
		}
		if (firstComponent != null) {
			var nextComponent = firstComponent;
			while (nextComponent != null) {
				remove(nextComponent);
				nextComponent = nextComponent.next;
			}
		}
		disposeChildren();
	}
}
