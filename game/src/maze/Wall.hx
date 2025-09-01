package maze;

import js.html.CanvasRenderingContext2D;

class Wall extends AbstractEntity{
	public var alive:Bool = true;
	public var visible:Bool = true;

	public function new(room:Room, x:Float, y:Float, w:Float = Room.CELL_SIZE, h:Float = Room.CELL_SIZE){
		super(room);
		aabb.w = w;
		aabb.h = h;
		this.x = x;
		this.y = y;
	}
	
	public function update(s:Float) {

	}

	public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D->Void {
		if(alive && visible){
			c.fillStyle = "#000";
			c.fillRect(x, y, aabb.w, aabb.h);
		}
		return null;
	}

	public function drawShadow(c:CanvasRenderingContext2D, lx:Float, ly:Float, d:Float) {
		if(alive && visible){
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
	}

	private function eachLine(callback:Float->Float->Float->Float->Void){
		callback(aabb.x-1, aabb.y-1, aabb.x + aabb.w+1, aabb.y-1); //top
		callback(aabb.x + aabb.w+1, aabb.y-1, aabb.x + aabb.w+1, aabb.y + aabb.h+1); // right
		callback(aabb.x + aabb.w+1, aabb.y + aabb.h+1, aabb.x-1, aabb.y + aabb.h+1); // bottom
		callback(aabb.x-1, aabb.y + aabb.h+1, aabb.x-1, aabb.y-1); // left
	}
}