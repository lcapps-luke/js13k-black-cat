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

	public function centerX() {
		return x + w / 2;
	}
	public function centerY() {
		return y + h / 2;
	}

	public function contains(ox, oy) {
		return !(
			ox < x ||
			ox > x + w ||
			oy < y ||
			oy > y + h
		);
	}

	@:native("mx")
	public function moveContactX(o:AABB, m:Float):Float {
		return moveContact(x, x + w, o.x, o.x + o.w, m);
	}

	@:native("my")
	public function moveContactY(o:AABB, m:Float):Float {
		return moveContact(y, y + h, o.y, o.y + o.h, m);
	}

	@:native("mc")
	private static function moveContact(l:Float, h:Float, ol:Float, oh:Float, m:Float):Float {
		var d:Float = (m > 0 ? ol - h : oh - l) * 0.9;
		return m > 0 ? Math.min(Math.abs(d), Math.abs(m)) : -Math.min(Math.abs(d), Math.abs(m));
	}
}