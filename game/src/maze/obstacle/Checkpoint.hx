package maze.obstacle;

import resource.Resources;
import js.html.ImageElement;
import math.AABB;
import js.html.CanvasRenderingContext2D;
using ui.ContextUtils;

class Checkpoint extends AbstractObstacle {
	private static inline var SOLID_RADIUS = 6;

	private var spawnX:Float;
	private var spawnY:Float;
	private var iBox:AABB;

	private var ia:ImageElement;
	private var ib:ImageElement;

	private var knockDelay:Float = 0;

	public function new(room:Room, x:Float, y:Float, spawnX:Float, spawnY:Float) {
		super(room);
		aabb.w = 48;
		aabb.h = 48;
		offset.set(24, 24);
		this.x = x;
		this.y = y;
		this.spawnX = spawnX;
		this.spawnY = spawnY;

		iBox = new AABB(x - 16, y - 16, 32, 32);
		ia = Resources.images.get(Resources.PLANTER);
		ib = Resources.images.get(Resources.BRANCHES);
	}

	public function update(s:Float) {
		if(iBox.overlaps(room.player.aabb)){
			room.interactionHint = "Knock on wood";

			if(Ctrl.actionPress){
				room.saveCheckpoint(spawnX, spawnY);
				Sound.knock();
				knockDelay = 0.4;
			}
		}

		if(knockDelay > 0){
			knockDelay -= s;
			if(knockDelay < 0){
				Sound.knock();
			}
		}
		
	}

	public function draw(c:CanvasRenderingContext2D) {
		c.drawImage(ia, aabb.x, aabb.y);
		return drawB;
	}

	public function drawB(c:CanvasRenderingContext2D):Void {
		c.drawImage(ib, aabb.x - 20, aabb.y - 14);
	}

	public function makeWall() {
		var w = new Wall(room, x - SOLID_RADIUS, y - SOLID_RADIUS, SOLID_RADIUS * 2, SOLID_RADIUS * 2);
		w.visible = false;
		return w;
	}
}