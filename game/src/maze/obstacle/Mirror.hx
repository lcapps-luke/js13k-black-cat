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
	var a:Float;

	public function new(room:Room, x:Float, y:Float, w:Float, h:Float, dir:String){
		super(room, x, y, w, h);
		i = Resources.images.get(Resources.MIRROR);
		iBox = new AABB(x - Room.CELL_SIZE / 2, y - Room.CELL_SIZE / 2, w + Room.CELL_SIZE, h + Room.CELL_SIZE);
		sax = dir == "w" ? w : 0;
		say = dir == "n" ? h : 0;
		sbx = dir == "e" ? 0 : w;
		sby = dir == "s" ? 0 : h;
		a = switch(dir){
			case "n": Math.PI;
			case "e": Math.PI * 1.5;
			case "w": Math.PI / 2;
			default: 0;
		}
	}

	override function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D -> Void {
		if(alive){
			c.save();
			c.translate(x + aabb.w / 2, y + aabb.h / 2);
			c.rotate(a);
			c.translate(-i.naturalWidth / 2, -i.naturalHeight / 2);
			c.drawImage(i, 0, 0);
			c.restore();
		}
		return null;
	}

	override function update(s:Float) {
		super.update(s);
		if(iBox.overlaps(room.player.aabb) && alive){
			room.interactionHint = "Smash";

			if(Ctrl.actionPress){
				alive = false;
				room.hurt(40);
				Sound.smash();
			}
		}
	}

	override function eachLine(callback:(Float, Float, Float, Float) -> Void) {
		callback(x + sax, y + say, x + sbx, y + sby);
	}
}