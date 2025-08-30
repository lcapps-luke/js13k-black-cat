package maze.obstacle;

import js.html.CanvasRenderingContext2D;

class CrackObstacle extends AbstractObstacle {
	private var over:Bool = false;

    public function new(room:Room, x:Float, y:Float, w:Float, h:Float) {
        super(room);
		aabb.w = w;
		aabb.h = h;
		this.x = x;
		this.y = y;
	}

	public function update(s:Float) {
		var playerOverlaps:Bool = room.player.aabb.overlaps(aabb);

		if(!over && playerOverlaps){
			over = true;
			room.hurt(10);
		}

		over = playerOverlaps;
	}

	public function draw(c:CanvasRenderingContext2D) {
		c.fillStyle = "#0F0";
		c.fillRect(x, y, aabb.w, aabb.h);
	}
}
