package maze.obstacle;

import math.AABB;
import js.html.CanvasRenderingContext2D;

class Switch extends Wall {
	public var walls:Array<Wall>;
	private var iBox:AABB;

	public function new(room:Room, x:Float, y:Float) {
		super(room, x, y);
		iBox = new AABB(x - Room.CELL_SIZE / 2, y - Room.CELL_SIZE / 2, Room.CELL_SIZE * 2, Room.CELL_SIZE * 2);
	}

	override function update(s:Float) {
		super.update(s);
		if(iBox.overlaps(room.player.aabb)){
			room.interactionHint = "Use Switch";

			if(Ctrl.actionPress){
				for(w in walls){
					w.alive = !w.alive;
				}
			}
		}
	}

	override function draw(c:CanvasRenderingContext2D) {
		c.fillStyle = "#f00";
		c.fillRect(x, y, aabb.w, aabb.h);
	}

	override function drawShadow(c:CanvasRenderingContext2D, lx:Float, ly:Float, d:Float) {
		// no shadow
	}
}