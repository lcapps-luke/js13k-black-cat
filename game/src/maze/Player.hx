package maze;

import js.html.CanvasRenderingContext2D;

using ui.ContextUtils;

class Player extends AbstractEntity {
	private static inline var MOVE_SPEED = 128;

	public function new(room:Room) {
		super(room);
		aabb.w = 32;
		aabb.h = 32;
		offsetX = 16;
		offsetY = 16;
	}

	public function update(s:Float) {
		var mx = Ctrl.left ? -1 : Ctrl.right ? 1 : 0;
		var my = Ctrl.up ? -1 : Ctrl.down ? 1 : 0;

		if (mx != 0 || my != 0) {
			var md = Math.atan2(my, mx);
			x += Math.cos(md) * MOVE_SPEED * s;
			y += Math.sin(md) * MOVE_SPEED * s;
		}
	}

	public function draw(c:CanvasRenderingContext2D) {
		c.beginPath();
		c.fillStyle = "blue";
		c.circle(x, y, 16);
		c.fill();
	}

}