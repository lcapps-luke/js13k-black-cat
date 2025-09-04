package maze;

import math.Vec2;
import js.html.CanvasRenderingContext2D;
import math.AABB;

abstract class AbstractEntity {
	private var room:Room;
	public var aabb(default, null):AABB = new AABB();

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;

	private var offset(default, null):Vec2 = new Vec2();

	public function new(room:Room){
		this.room = room;
	}

	abstract public function update(s:Float):Void;
	abstract public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D->Void;
	public function drawShadow(c:CanvasRenderingContext2D, lx:Float, ly:Float, lr:Float){
		// Override if you want to cast a shadow
	}

	function set_x(value:Float):Float {
		aabb.x = value - offset.x;
		return x = value;
	}

	function set_y(value:Float):Float {
		aabb.y = value - offset.y;
		return y = value;
	}
}