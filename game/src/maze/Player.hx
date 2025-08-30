package maze;

import math.Vec2;
import js.lib.Math;
import js.html.ImageElement;
import resource.Resources;
import math.AABB;
import js.html.CanvasRenderingContext2D;

using ui.ContextUtils;

class Player extends AbstractEntity {
	private static inline var MOVE_SPEED = 128;

	private var nextAABB = new AABB();
	private var i:ImageElement;

	private var a:Float = 0;
	private var sa:Vec2 = new Vec2();
	private var sb:Vec2 = new Vec2();

	public function new(room:Room) {
		super(room);
		aabb.w = Room.CELL_SIZE;
		aabb.h = Room.CELL_SIZE;
		offset.set(Room.CELL_SIZE / 2, Room.CELL_SIZE / 2);

		nextAABB.w = aabb.w;
		nextAABB.h = aabb.h;

		this.i = Resources.images.get("p");
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

			this.a = Math.atan2(my, mx);
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
		c.save();
		c.translate(x, y);
		c.rotate(a);
		c.translate(-offset.x, -offset.y);
		c.drawImage(i, 0, 0);
		c.restore();
	}


	public function drawShadow(c:CanvasRenderingContext2D, lx:Float, ly:Float, lr:Float) {
		var ldir = Math.atan2(y - ly, x - lx);

		var ax = x + Math.cos(ldir + Math.PI * 0.5) * -5;
		var ay = y + Math.sin(ldir + Math.PI * 0.5) * -5;
		var bx = x + Math.cos(ldir + Math.PI * 0.5) * 5;
		var by = y + Math.sin(ldir + Math.PI * 0.5) * 5;

		var da:Float = Math.atan2(ay - ly, ax - lx);
		var db:Float = Math.atan2(by - ly, bx - lx);

		var d = Math.sqrt(Math.pow(this.x - lx, 2) + Math.pow(this.y - ly, 2));

		var cpx = x + Math.cos(ldir) * (d * 1.5 + 10);
		var cpy = y + Math.sin(ldir) * (d * 1.5 + 10);

		c.filter = "blur(2px)";
		c.beginPath();
		c.moveTo(ax, ay);
		c.quadraticCurveTo(x + Math.cos(ldir) * 5, y + Math.sin(ldir) * 5, bx, by);
		c.lineTo(bx + Math.cos(db) * d, by + Math.sin(db) * d);
		c.quadraticCurveTo(cpx, cpy, ax + Math.cos(da) * d, ay + Math.sin(da) * d);
		c.lineTo(ax, ay);
		c.fill();
	}
}