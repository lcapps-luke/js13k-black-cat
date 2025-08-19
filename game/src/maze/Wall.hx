package maze;

import js.html.CanvasRenderingContext2D;

class Wall extends AbstractEntity{

	public function new(room:Room){
		super(room);
		aabb.w = 32;
		aabb.h = 32;
	}
	
	public function update(s:Float) {

	}

	public function draw(c:CanvasRenderingContext2D) {
		c.fillStyle = "#000";
		c.fillRect(x, y, 32, 32);
	}

	public function drawShadow(c:CanvasRenderingContext2D, lx:Float, ly:Float, d:Float) {
		eachLine((ax,ay,bx,by) -> {
			var da:Float = Math.atan2(ay - ly, ax - lx);
			var db:Float = Math.atan2(by - ly, bx - lx);

			c.beginPath();
			c.moveTo(ax, ay);
			c.lineTo(bx, by);
			c.lineTo(bx + Math.cos(db) * d, by + Math.sin(db) * d);
			c.lineTo(ax + Math.cos(da) * d, ay + Math.sin(da) * d);
			c.lineTo(ax, ay);
			c.fill();
		});
	}

	private function eachLine(callback:Float->Float->Float->Float->Void){
		callback(aabb.x, aabb.y, aabb.x + aabb.w, aabb.y); //top
		callback(aabb.x + aabb.w, aabb.y, aabb.x + aabb.w, aabb.y + aabb.h); // right
		callback(aabb.x + aabb.w, aabb.y + aabb.h, aabb.x, aabb.y + aabb.h); // bottom
		callback(aabb.x, aabb.y + aabb.h, aabb.x, aabb.y); // left
	}
}