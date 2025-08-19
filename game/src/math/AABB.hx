package math;

class AABB{
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;

	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0){
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public function overlaps(o:AABB):Bool{
		return !(
			x + w < o.x ||
			x > o.x + o.w ||
			y + h < o.y ||
			y > o.y + o.h
		);
	}
}