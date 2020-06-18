package gasm.core.math.geom;

@:structInit
class Area {
	public function new(x = 0, y = 0, w = 0, h = 0) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public var x:Int = 0;
	public var y:Int = 0;
	public var w:Int = 0;
	public var h:Int = 0;
}
