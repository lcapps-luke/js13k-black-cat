package maze.obstacle;

import resource.Resources;
import js.html.ImageElement;
import math.AABB;
import js.html.CanvasRenderingContext2D;

class Switch extends Wall {
	public var walls:Array<Wall>;
	private var iBox:AABB;

	var i:ImageElement;

	public function new(room:Room, x:Float, y:Float) {
		super(room, x, y);
		iBox = new AABB(x - Room.CELL_SIZE / 2, y - Room.CELL_SIZE / 2, Room.CELL_SIZE * 2, Room.CELL_SIZE * 2);
		i = Resources.images.get(Resources.SWITCH);
		visible = false;
	}

	override function update(s:Float) {
		super.update(s);
		if(iBox.overlaps(room.player.aabb)){
			room.interactionHint = "Use Switch";

			if(Ctrl.actionPress){
				for(w in walls){
					w.alive = !w.alive;
				}
				Sound.click();
			}
		}
	}

	override function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D->Void {
		c.drawImage(i, aabb.x, aabb.y);
		return null;
	}
}