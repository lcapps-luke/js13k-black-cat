package maze.obstacle;

import js.html.CanvasRenderingContext2D;

class CatRegion extends AbstractObstacle{
	private static inline var DPS = 20;
	private static inline var RANGE = 48;

	
	private var cat:Cat;
	public function new(room:Room, x:Int, y:Int, rx:Float, ry:Float, rw:Float, rh:Float){
		super(room);
		aabb.w = rw;
		aabb.h = rh;
		this.x = rx;
		this.y = ry;

		cat = new Cat(room, x, y, this);
	}

	public function update(s:Float) {
		cat.update(s);

		if(aabb.overlaps(room.player.aabb)){
			var dx = room.player.x - cat.x;
			var dy = room.player.y - cat.y;
			var d = Math.sqrt(dx * dx + dy * dy);
			if(d < RANGE){
				room.hurt(DPS * s);
				cat.mew();
			}
		}
	}

	public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D -> Void {
		if(room.camera.overlaps(cat.aabb)){
			cat.draw(c);
		}
		return null;
	}
}