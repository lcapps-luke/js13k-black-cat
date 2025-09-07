package maze.obstacle;

import math.AABB;
import resource.Resources;
import js.html.ImageElement;
import js.html.CanvasRenderingContext2D;

class Mirror extends Wall{
	private var i:ImageElement;

	private var iBox:AABB;
	var sax:Float;
	var say:Float;
	var sbx:Float;
	var sby:Float;

	public function new(room:Room, x:Float, y:Float, w:Float, h:Float, dir:String){
		super(room, x, y, w, h);
		i = Resources.images.get(Resources.MIRROR);
		iBox = new AABB(x - Room.CELL_SIZE / 2, y - Room.CELL_SIZE / 2, Room.CELL_SIZE * 2, Room.CELL_SIZE * 2);
		sax = dir == "w" ? w : 0;
		say = dir == "n" ? h : 0;
		sbx = dir == "e" ? 0 : w;
		sby = dir == "s" ? 0 : h;
	}

	override function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D -> Void {
		if(alive){
			c.drawImage(i, x, y);
		}
		return null;
	}

	override function update(s:Float) {
		super.update(s);
		if(iBox.overlaps(room.player.aabb)){
			room.interactionHint = "Smash";

			if(Ctrl.actionPress){
				alive = false;
			}
		}
	}

	override function eachLine(callback:(Float, Float, Float, Float) -> Void) {
		callback(x + sax, y + say, x + sbx, y + sby);
	}
}