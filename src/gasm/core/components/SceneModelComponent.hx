package gasm.core.components;

import gasm.core.Component;
import gasm.core.enums.ComponentType;
import haxe.ds.StringMap;

using Lambda;

class SceneModelComponent extends Component {
	public var scenes:Array<SceneLayer> = [];
	public var dirty(default, null) = false;
	public var sceneMap = new StringMap<Any>();

	public function new() {
		componentType = ComponentType.SceneModel;
	}

	public function addScene(scene:SceneLayer):Entity {
		scene.entity = new Entity(scene.name);
		if (scene.layerIndex == null) {
			scene.layerIndex = scenes.length;
		}
		scenes.push(scene);
		scenes.sort((a, b) -> a.layerIndex > b.layerIndex ? 1 : -1);
		var i = 0;
		scenes.map(s -> s.layerIndex = i++);
		addEntity(scene, owner);
		dirty = true;
		return scene.entity;
	}

	/**
	 * Disable interactivity for a scene
	 * @param name Name of scene to disable
	 */
	public function disableScene(name:String) {
		// Override in integration
	}

	/**
	 * Enable interactivity for a scene
	 * @param name Name of scene to disable
	 */
	public function enableScene(name:String) {
		// Override in integration
	}

	public function removeScene(name:String) {
		var scene = scenes.find(s -> s.name == name);
		if (scene != null) {
			var s = sceneMap.get(scene.name);
			var s2d:h2d.Scene = s;
			if (s2d != null) {
				s2d.remove();
			}
			var s3d:h3d.scene.Scene = s;
			if (s3d != null) {
				s3d.remove();
			}
			if (scene.entity.parent != null) {
				scene.entity.parent.removeChild(scene.entity);
			}
			scene.entity.dispose();
			dirty = true;
		}
	}

	function addEntity(scene:SceneLayer, baseEntity:Entity):Entity {
		// Override in integration
		return null;
	}
}

@:structInit
class SceneLayer {
	public var name:String;
	public var is3D = false;
	public var layerIndex:Null<Int> = null;
	public var interactive = false;
	public var entity:Entity = null;
}
