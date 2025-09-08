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

	private var stepTimer:Float = 0;

	public function new(room:Room) {
		super(room);
		aabb.w = 13;
		aabb.h = 13;
		offset.set(aabb.w / 2, aabb.h / 2);

		nextAABB.w = aabb.w;
		nextAABB.h = aabb.h;

		this.i = Resources.images.get(Resources.PLAYER);
	}

	public function update(s:Float) {
		var cx = Ctrl.left ? -1 : Ctrl.right ? 1 : 0;
		var cy = Ctrl.up ? -1 : Ctrl.down ? 1 : 0;

		var mx = 0.0;
		var my = 0.0;

		if (cx != 0 || cy != 0) {
			this.a = Math.atan2(cy, cx);
			mx = Math.cos(this.a) * MOVE_SPEED * s;
			my = Math.sin(this.a) * MOVE_SPEED * s;
		}

		nextAABB.x = aabb.x + mx;
		nextAABB.y = aabb.y;

		room.walls.forEachIn(nextAABB, w -> {
			if(w.alive){
				mx = aabb.moveContactX(w.aabb, mx);
				if (mx != 0) {
					mx = mx > 0 ? mx - 0.2 : mx + 0.2;
				}
			}
		});

		nextAABB.x = aabb.x;
		nextAABB.y = aabb.y + my;

		room.walls.forEachIn(nextAABB, w -> {
			if(w.alive){
				my = aabb.moveContactY(w.aabb, my);
				if (my != 0) {
					my = my > 0 ? my - 0.2 : my + 0.2;
				}
			}
		});

		x += mx;
		y += my;

		if(mx != 0 || my != 0){
			stepTimer -= s;
			if(stepTimer < 0){
				stepTimer = 0.35;
				Sound.step();
			}
		}
	}

	public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D->Void {
		c.save();
		c.translate(x, y);
		c.rotate(a);
		c.translate(-i.naturalWidth / 2, -i.naturalHeight / 2);
		c.drawImage(i, 0, 0);
		c.restore();
		return null;
	}


	override public function drawShadow(c:CanvasRenderingContext2D, lx:Float, ly:Float, lr:Float) {
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
		c.filter = "";
	}
}