package maze;

import js.html.CanvasRenderingContext2D;
import js.html.ImageElement;

class Decal extends AbstractEntity{
	private var i:ImageElement;
	private var a:Float;
	public function new(room:Room, x:Float,y:Float,w:Float,h:Float,i:ImageElement,a:Float){
		super(room);
		aabb.w = w;
		aabb.h = h;
		this.x = x;
		this.y = y;
		this.i = i;
		this.a = a;
	}

	public function update(s:Float) {}

	public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D -> Void {
		c.save();
		c.translate(x + aabb.w / 2, y + aabb.h / 2);
		c.rotate(a);
		c.translate(-i.naturalWidth / 2, -i.naturalHeight / 2);
		c.drawImage(i, 0, 0);
		c.restore();
		return null;
	}
}