package maze.obstacle;

import js.html.CanvasRenderingContext2D;
using ui.ContextUtils;

class Checkpoint extends AbstractObstacle {
	private var spawnX:Float;
	private var spawnY:Float;

	public function new(room:Room, x:Float, y:Float, spawnX:Float, spawnY:Float) {
		super(room);
		aabb.w = 48;
		aabb.h = 48;
		offset.set(24, 24);
		this.x = x;
		this.y = y;
		this.spawnX = spawnX;
		this.spawnY = spawnY;
	}

	public function update(s:Float) {
		var playerOverlaps:Bool = room.player.aabb.overlaps(aabb);

		if(playerOverlaps){
			//TODO interaction hint
		}
	}

	public function draw(c:CanvasRenderingContext2D) {
		c.beginPath();
		c.fillStyle = "#0f0";
		c.circle(x, y, 24);
		c.fill();
	}
}