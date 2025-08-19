package maze;

import js.html.CanvasRenderingContext2D;
import math.AABB;

abstract class AbstractEntity {
	private var room:Room;
	public var aabb(default, null):AABB = new AABB();

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;

	private var offsetX(default, set):Float = 0;
	private var offsetY(default, set):Float = 0;

	public function new(room:Room){
		this.room = room;
	}

	abstract public function update(s:Float):Void;
	abstract public function draw(c:CanvasRenderingContext2D):Void;

	function set_x(value:Float):Float {
		aabb.x = value - offsetX;
		return x = value;
	}

	function set_y(value:Float):Float {
		aabb.y = value - offsetY;
		return y = value;
	}

	function set_offsetX(value:Float):Float {
		aabb.x = x - value;
		return offsetX = value;
	}

	function set_offsetY(value:Float):Float {
		aabb.y = y - value;
		return offsetY = value;
	}
}