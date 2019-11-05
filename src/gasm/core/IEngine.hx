package gasm.core;

/**
 * @author Leo Bergman
 */
interface IEngine {
	public var baseEntity(default, null):Entity;
	public var getDelta:Null<() -> Float>;
	public function tick():Void;
	public function pause():Void;
	public function resume():Void;
}
