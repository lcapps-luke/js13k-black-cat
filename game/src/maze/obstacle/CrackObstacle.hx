package maze.obstacle;

import resource.Resources;
import js.html.ImageElement;
import js.html.CanvasRenderingContext2D;

class CrackObstacle extends AbstractObstacle {
	private var over:Bool = false;
	private var i:ImageElement;
	var a:Float;

    public function new(room:Room, x:Float, y:Float, w:Float, h:Float) {
        super(room);
		aabb.w = w;
		aabb.h = h;
		this.x = x;
		this.y = y;
		this.i = Resources.images.get(Resources.CRACK);
		a = w > h ? Math.PI / 2 : 0;
	}

	public function update(s:Float) {
		var playerOverlaps:Bool = room.player.aabb.overlaps(aabb);

		if(!over && playerOverlaps){
			over = true;
			room.hurt(10);
			Sound.crack();
		}

		over = playerOverlaps;
	}

	public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D->Void {
		//c.drawImage(i, x, y, aabb.w, aabb.h);
		c.save();
		c.translate(x + aabb.w / 2, y + aabb.h / 2);
		c.rotate(a);
		c.translate(-i.naturalWidth / 2, -i.naturalHeight / 2);
		c.drawImage(i, 0, 0);
		c.restore();
		return null;
	}
}
