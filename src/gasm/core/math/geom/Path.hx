package gasm.core.math.geom;

import h3d.Matrix;
import h3d.Quat;
import h3d.Vector;

using Safety;

/**
	Abstract over Arrays of vectors providing useful functions when working with connected lines forming a path.
**/
@:forward
abstract Path(Array<Vector>) from Array<Vector> to Array<Vector> {
	public function new(?points:Array<Vector>) {
		this = points.or(new Array<Vector>());
	}

	/**
		Get direction and position of every mid-section of a path segment
		pointB...<mid>...pointB
		@return Matrix for every midpoint
	**/
	public function getMidpoints():Array<Matrix> {
		return [
			for (i in 0...this.length - 1) {
				final pointA = this[i];
				final pointB = this[i + 1];
				// Calculate rotation by direction
				final dir = pointB.sub(pointA);
				dir.normalize();
				final rotation = Matrix.lookAtX(dir);
				// Calculate position
				final position = new h3d.Vector();
				position.x = pointA.x + (pointB.x - pointA.x) * 0.5;
				position.y = pointA.y + (pointB.y - pointA.y) * 0.5;
				position.z = pointA.z + (pointB.z - pointA.z) * 0.5;
				final m = new h3d.Matrix();
				m.identity();
				m.setPosition(position);
				m.multiply(rotation, m);
				m;
			}
		];
	}
}
