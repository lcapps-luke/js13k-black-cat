package maze.obstacle;

import resource.Resources;
import js.html.ImageElement;
import math.Vec2;
import math.AABB;
import js.html.CanvasRenderingContext2D;

class Cat extends AbstractEntity{
	private static inline var LOOK_AHEAD = 12;
	private static inline var MOVE_SPEED = 50;

	private var region:CatRegion;
	private var md = new Vec2();
	private var cr = new AABB(0, 0, 16, 16);

	private var i:ImageElement;
	private var a:Float = 0;

	public function new(room:Room, x:Float, y:Float, region:CatRegion) {
		super(room);
		aabb.w = 16;
		aabb.h = 16;
		offset.set(8, 8);
		this.x = x;
		this.y = y;
		this.region = region;

		i = Resources.images.get(Resources.CAT);
	}

	public function update(s:Float) {
		if(md.x == 0 && md.y == 0){
			var d = Math.floor(Math.random() * 4);
			switch(d){
				case 0: md.x = -1;
				case 1: md.x = 1;
				case 2: md.y = -1;
				case 3: md.y = 1;
			}
			a = Math.atan2(md.y, md.x);
		}

		// look ahead
		if(isBlocked(md.x, md.y)){
			pickNewDirection();
		}

		// move
		x += md.x * MOVE_SPEED * Math.min(s, 0.16);
		y += md.y * MOVE_SPEED * Math.min(s, 0.16);
	}

	private function isBlocked(dx:Float, dy:Float){
		cr.x = x + (dx * LOOK_AHEAD) - cr.w / 2;
		cr.y = y + (dy * LOOK_AHEAD) - cr.h / 2;

		if(!region.aabb.overlaps(cr)){
			return true;
		}

		var blocked = false;
		room.walls.forEachIn(cr, w->{
			blocked = true;
		});
		return blocked;
	}

	private function pickNewDirection(){
		var lr = (Math.random() > 0.5) ? 1 : -1;
		var ox = md.x;
		var oy = md.y;

		var co = [
			[oy * lr, ox * lr],
			[-oy * lr, -ox * lr],
			[-ox, -oy]
		];

		var nd = firstFree(co);
		md.set(nd[0], nd[1]);
		a = Math.atan2(md.y, md.x);
	}

	private function firstFree(xyl:Array<Array<Float>>){
		for(xy in xyl){
			if(!isBlocked(xy[0], xy[1])){
				return xy;
			}
		}
		return [0,0];
	}

	public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D -> Void {
		c.save();
		c.translate(x, y);
		c.rotate(a);
		c.translate(-i.naturalWidth / 2, -i.naturalHeight / 2);
		c.drawImage(i, 0, 0);
		c.restore();
		return null;

		/*
		c.fillStyle = "#0F0";
		c.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
		return null;
		*/
	}
}