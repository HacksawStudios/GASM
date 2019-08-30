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
		removeScene(scene.name);
		scene.entity = new Entity(scene.name);
		if (scene.layerIndex == null) {
			scene.layerIndex = scenes.length;
		}
		scenes.push(scene);
		sortScenes();
		addEntity(scene, owner);
		dirty = true;
		return scene.entity;
	}

	/**
	 * Make scene invisible
	 * @param name Name of scene to make invisible
	 */
	public function hideScene(name:String) {
		// Override in integration
	}

	/**
	 * Make scene visible
	 * @param name Name of scene to make visible
	 */
	public function showScene(name:String) {
		// Override in integration
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
		final scene = scenes.find(s -> s.name == name);
		if (scene != null) {
			final s2d:h2d.Scene = scene.instance;
			if (s2d != null) {
				s2d.removeChildren();
				s2d.remove();
				s2d.dispose();
			}
			final s3d:h3d.scene.Scene = scene.instance;
			if (s3d != null) {
				s3d.removeChildren();
				s3d.remove();
				s3d.dispose();
			}
			if (scene.entity.parent != null) {
				scene.entity.parent.removeChild(scene.entity);
			}
			scene.entity.dispose();
			dirty = true;
			scenes.remove(scene);
			sceneMap.remove(scene.name);
		}
	}

	public function moveToTop(name:String) {
		final scene = scenes.find(val -> name == val.name);
		if (scene != null) {
			scene.layerIndex = scenes.length;
			sortScenes();
		}
	}

	public function moveToBottom(name:String) {
		final scene = scenes.find(val -> name == val.name);
		if (scene != null) {
			scene.layerIndex = -1;
			sortScenes();
		}
	}

	public function swapDepths(nameA:String, nameB:String) {
		final sceneA = scenes.find(val -> nameA == val.name);
		final sceneB = scenes.find(val -> nameB == val.name);
		final layerIndexA = sceneA.layerIndex;
		final layerIndexB = sceneB.layerIndex;
		sceneA.layerIndex = layerIndexB;
		sceneB.layerIndex = layerIndexA;
		sortScenes();
	}

	function addEntity(scene:SceneLayer, baseEntity:Entity):Entity {
		// Override in integration
		return null;
	}

	function sortScenes() {
		scenes.sort((a, b) -> a.layerIndex > b.layerIndex ? 1 : -1);
		var i = 0;
		scenes.map(s -> {
			s.layerIndex = i++;
			return s;
		});
	}
}

@:structInit
class SceneLayer {
	public var name:String;
	public var is3D = false;
	public var layerIndex:Null<Int> = null;
	public var interactive = false;
	public var entity:Entity = null;
	public var instance:Any = null;
}
