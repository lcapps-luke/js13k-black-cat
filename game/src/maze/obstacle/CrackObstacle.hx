package maze.obstacle;

import resource.Resources;
import js.html.ImageElement;
import js.html.CanvasRenderingContext2D;

class CrackObstacle extends AbstractObstacle {
	private var over:Bool = false;
	private var i:ImageElement;

    public function new(room:Room, x:Float, y:Float, w:Float, h:Float) {
        super(room);
		aabb.w = w;
		aabb.h = h;
		this.x = x;
		this.y = y;
		this.i = Resources.images.get("c");
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
		c.drawImage(i, x, y, aabb.w, aabb.h);
	}
}
