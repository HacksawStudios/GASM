package gasm.core.math.geom;

@:structInit
class Rectangle {
	public function new(x = 0.0, y = 0.0, w = 0.0, h = 0.0) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public var x:Float = 0;

	public var y:Float = 0;
	public var w:Float = 0;
	public var h:Float = 0;
}
