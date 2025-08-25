package maze;

import math.AABB;
import js.html.CanvasRenderingContext2D;

using ui.ContextUtils;

class Player extends AbstractEntity {
	private static inline var MOVE_SPEED = 128;

	private var nextAABB = new AABB();

	public function new(room:Room) {
		super(room);
		aabb.w = Room.CELL_SIZE;
		aabb.h = Room.CELL_SIZE;
		offset.set(Room.CELL_SIZE / 2, Room.CELL_SIZE / 2);

		nextAABB.w = aabb.w;
		nextAABB.h = aabb.h;
	}

	public function update(s:Float) {
		var cx = Ctrl.left ? -1 : Ctrl.right ? 1 : 0;
		var cy = Ctrl.up ? -1 : Ctrl.down ? 1 : 0;

		var mx = 0.0;
		var my = 0.0;

		if (cx != 0 || cy != 0) {
			var md = Math.atan2(cy, cx);
			mx = Math.cos(md) * MOVE_SPEED * s;
			my = Math.sin(md) * MOVE_SPEED * s;
		}

		nextAABB.x = aabb.x + mx;
		nextAABB.y = aabb.y;

		room.walls.forEachIn(nextAABB, w -> {
			mx = aabb.moveContactX(w.aabb, mx);
			if (mx != 0) {
				mx = mx > 0 ? mx - 0.2 : mx + 0.2;
			}
		});

		nextAABB.x = aabb.x;
		nextAABB.y = aabb.y + my;

		room.walls.forEachIn(nextAABB, w -> {
			my = aabb.moveContactY(w.aabb, my);
			if (my != 0) {
				my = my > 0 ? my - 0.2 : my + 0.2;
			}
		});

		x += mx;
		y += my;
	}

	public function draw(c:CanvasRenderingContext2D) {
		c.beginPath();
		c.fillStyle = "blue";
		c.circle(x, y, offset.x);
		c.fill();
	}

}