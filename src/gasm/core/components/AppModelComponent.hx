package gasm.core.components;

import gasm.core.api.singnals.TResize;
import gasm.core.enums.ComponentType;
import gasm.core.enums.Orientation;
import gasm.core.math.geom.Point;
import gasm.core.utils.Signal1;
import haxe.ds.StringMap;

using StringTools;
using thx.Arrays;

class AppModelComponent extends Component {
	/**
	 * Device orientation.
	**/
	public var orientation:Orientation;

	public var stageSize:Point = {x: 0, y: 0};
	public var scale:Float = 1.0;
	public var resizeSignal:Signal1<TResize>;
	public var stageMouseX:Float;
	public var stageMouseY:Float;
	public var frozen:Bool = true;
	public var freezeSignal:Signal1<Bool>;
	public var customRenderCallback:Null<(engine:Any) -> Void> = null;
	public var pixelRatio = 1.0;
	public var assetsPath:String;
	public var disableShaderDevices = new StringMap<Array<String>>();
	public var enableShaderDevices = new StringMap<Array<String>>();

	public function new() {
		componentType = ComponentType.Model;
		resizeSignal = new Signal1<TResize>();
		freezeSignal = new Signal1<Bool>();
	}

	public function isShaderEnabled(name:String) {
		#if js
		final ua:String = js.Syntax.code('window.navigator.userAgent');
		if (enableShaderDevices != null && enableShaderDevices.exists(name)) {
			final enabled = enableShaderDevices.get(name).any(dev -> ua.contains(dev));
			if (enabled) {
				return true;
			}
		}
		trace('disableShaderDevices', disableShaderDevices);
		if (disableShaderDevices.exists(name)) {
			final disabled = disableShaderDevices.get(name).any(dev -> ua.contains(dev));
			return !disabled;
		}
		#end
		return true;
	}
}
