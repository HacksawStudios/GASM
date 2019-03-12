package gasm.core.math.geom;

@:structInit
class Vector {
	public var x = 0.;
	public var y = 0.;
	public var z = 0.;

	public function new(x = 0., y = 0., z = 0.) {
		set(x, y, z);
	}

	public function set(x = 0., y = 0., z = 0.) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
}
