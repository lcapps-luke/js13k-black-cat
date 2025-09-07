package maze.obstacle;

import js.html.CanvasRenderingContext2D;

class Ladder extends AbstractObstacle {
	private static inline var RUNG_SPACING = 8;
	private static inline var MAX_HEIGHT = 0.5;

	private var lines:Array<Array<Array<Float>>>;
	private var over:Bool = false;

	public function new(room:Room, x:Float, y:Float, w:Float, h:Float) {
		super(room);
		aabb.w = w;
		aabb.h = h;
		this.x = x;
		this.y = y;

		var vrt = h > w;

		lines = [
			[[0, 0, MAX_HEIGHT], [vrt ? 0 : w, vrt ? h : 0, MAX_HEIGHT]],// left/top
			[[vrt ? w : 0, vrt ? 0 : h, MAX_HEIGHT], [w, h, MAX_HEIGHT]], //right/bottom
		];
		
		var rungCount = Math.floor((vrt ? h : w) / RUNG_SPACING);
		for(i in 1...rungCount){
			var pos = i * RUNG_SPACING;
			var z = MAX_HEIGHT;//(1 - pos / (vrt ? h : w)) * MAX_HEIGHT;
			lines.push([
				[vrt ? 0 : pos, vrt ? pos : 0, z],
				[vrt ? w : pos, vrt ? pos : h, z]
			]);
		}
	}
	
	public function update(s:Float) {
		var playerOverlaps:Bool = room.player.aabb.overlaps(aabb);

		if(!over && playerOverlaps){
			over = true;
			room.hurt(20);
		}

		over = playerOverlaps;
	}

	public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D -> Void {
		return drawLadder;
	}

	public function drawLadder(c:CanvasRenderingContext2D){
		c.lineWidth = 4;
		c.strokeStyle = "#000";//"#420";
		
		for(l in lines){
			c.beginPath();
			c.moveTo(x + l[0][0], y + l[0][1]);
			c.lineTo(x + l[1][0], y + l[1][1]);
			c.stroke();
		}
	}

	override public function drawShadow(c:CanvasRenderingContext2D, lx:Float, ly:Float, lr:Float){
		c.lineWidth = 4;
		
		for(l in lines){
			var ax = x + l[0][0];
			var ay = y + l[0][1];
			var az = l[0][2];

			var bx = x + l[1][0];
			var by = y + l[1][1];
			var bz = l[1][2];

			var ad = Math.sqrt(Math.pow(ax - lx, 2) + Math.pow(ay - ly, 2));
			var bd = Math.sqrt(Math.pow(bx - lx, 2) + Math.pow(by - ly, 2));
			var aa:Float = Math.atan2(ay - ly, ax - lx);
			var ba:Float = Math.atan2(by - ly, bx - lx);

			c.beginPath();
			c.moveTo(ax + Math.cos(aa) * ad * az, ay + Math.sin(aa) * ad * az);
			c.lineTo(bx + Math.cos(ba) * bd * bz, by + Math.sin(ba) * bd * bz);
			c.stroke();
		}
	}
}