package gasm.core;
import gasm.core.components.SoundModelComponent;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Type.ClassType;
import gasm.core.components.SpriteModelComponent;
import gasm.core.components.TextModelComponent;
import gasm.core.enums.ComponentType;

using Lambda;
using gasm.core.utils.BitUtils;
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
    public var parent (default, null) :Entity = null;

    /** This entity's first child. */
    public var firstChild (default, null) :Entity = null;

    /** This entity's next sibling, for iteration. */
    public var next (default, null) :Entity = null;

    /** This entity's first component. */
    public var firstComponent (default, null) :Component = null;

    private var _compMap :Map<String, Component>;
	public var id(default, null):Int;
	
    public function new ()
    {
		_compMap = new Map<String, Component>();
    }

    /**
     * Add a component to this entity. Any previous component of this type will be replaced.
     * @returns This instance, for chaining.
     */
    public function add (component :Component) :Entity
    {
        if (component.owner != null) 
		{
            component.owner.remove(component);
        }
        var baseName = component.baseName;
        var prev = _compMap.get(baseName);
        if (prev != null) 
		{
            remove(prev);
        }
        _compMap.set(baseName, component);


        var tail = null;
		var comp = firstComponent;

        while (comp != null) 
		{
            tail = comp;
            comp = comp.next;
        }
        if (tail != null) 
		{
            tail.next = component;
        } 
		else 
		{
            firstComponent = component;
        }
        component.owner = this;
        component.next = null;
		if (component.componentType == Graphics)
		{
			add(new SpriteModelComponent());
		}		
		else if (component.componentType == Text)
		{
			add(new SpriteModelComponent());
		}
		else if (component.componentType == Sound)
		{
			add(new SoundModelComponent());
		}
		component.setup();
        return this;
    }

    /**
     * Remove a component from this entity.
     * @return Whether the component was removed.
     */
    public function remove(component:Component):Bool
    {
        var prev:Component = null;
		var comp = firstComponent;
        while (comp != null) 
		{
            var next = comp.next;
            if (comp == component) 
			{
                // Splice out the component
                if (prev == null) 
				{
                    firstComponent = next;
                } 
				else 
				{
                    prev.owner = this;
                    prev.next = next;
                }
				_compMap.remove(comp.name);
                if (comp.inited) 
				{
                    comp.dispose();
                }
                comp.owner = null;
                comp.next = null;
                return true;
            }
            prev = comp;
            comp = next;
        }
        return false;
    }

#if display
	public function get<T:Component>(componentClass:Class<T>):T 
	{
	}
#else
	
#end
	
#if display
public function get<T:Component>(componentClass:Class<T>):T 
	{
	}    
public function getFromParents<T:Component> (componentClass:Class<T>):T
	{
		return null;
	}	
#else
	macro public function get<T:Component>(self:Expr, componentClass:ExprOf<Class<T>>):ExprOf<T>
	{
		var componentName = macro $componentClass.BASE_NAME;		
		return macro Std.instance($self.getComponentByName($componentName), $componentClass);
	}
	inline public function getComponentByName(name:String):Component
    {
        return _compMap.get(name);
    }
    
	macro public function getFromParents<T:Component> (self:Expr, componentClass:ExprOf<Class<T>>):ExprOf<T>
    {
        var name = macro $componentClass.BASE_NAME;
        return macro $self.getFromParentsByName($name, $componentClass);
    }
	public function getFromParentsByName<T:Component> (name:String, castToClass:Class<T>):T
    {
        var entity = this;
		while (entity != null) {
            var component = entity.getComponentByName(name);
            component = Std.instance(component, castToClass);
			if (component != null) {
				return cast component;
			}
            entity = entity.parent;
        };
        return null;
    }
#end
	
	/*public function get<T>(clazz:Class<T>):T
	{
		var name = Type.getClassName(clazz);
		if (_compMap.exists(name))
		{
			return cast _compMap.get(name);
		}
		else
		{
			var nextClazz:Class<Dynamic> = Type.getSuperClass(clazz);
			if (nextClazz == Component)
			{
				return null;
			}
			return get(nextClazz);
		}
	}
*/
    /**
     * Adds a child to this entity.
     * @param append Whether to add the entity to the end or beginning of the child list.
     * @returns This instance, for chaining.
     */
    public function addChild (entity :Entity, append :Bool=true) :Entity
    {
        if (entity.parent != null)
		{
            entity.parent.removeChild(entity);
        }
        entity.parent = this;
        if (append) 
		{
            var tail = null;
			var current = firstChild;
            while (current != null) 
			{
                tail = current;
                current = current.next;
            }
            if (tail != null) 
			{
                tail.next = entity;
            } 
			else 
			{
                firstChild = entity;
            }
        } 
		else 
		{
            entity.next = firstChild;
            firstChild = entity;
        }
        return this;
    }

    public function removeChild (entity :Entity)
    {
        var prev :Entity = null;
		var current = firstChild;
        while (current != null) 
		{
            var next = current.next;
            if (current == entity) 
			{
                if (prev == null) 
				{
                    firstChild = next;
                } 
				else 
				{
                    prev.next = next;
                }
                current.parent = null;
                current.next = null;
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
    public function disposeChildren ()
    {
        while (firstChild != null) 
		{
            firstChild.dispose();
        }
    }

    /**
     * Removes this entity from its parent, and disposes all its components and children.
     */
    public function dispose ()
    {
        if (parent != null) 
		{
            parent.removeChild(this);
        }
        while (firstComponent != null) 
		{
            firstComponent.dispose();
        }
        disposeChildren();
    }
    
}