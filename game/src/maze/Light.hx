package maze;

import js.html.CanvasGradient;
import js.html.CanvasRenderingContext2D;
using ui.ContextUtils;

class Light extends AbstractEntity{
	private var shadowCtx:CanvasRenderingContext2D;
	private var grad:CanvasGradient;

	private var lastX:Float = null;
	private var lastY:Float = null;
	
	private var colour:String;
	private var dirty = true;

	public function new(room:Room, radius:Float, colour:String){
		super(room);
		aabb.w = radius * 2;
		aabb.h = radius * 2;
		offsetX = radius;
		offsetY = radius;

		this.colour = colour;

		shadowCtx = Room.newCanvas();
	}

	public function update(s:Float) {
		if(lastX == null || lastY == null || lastX != x || lastY != y){
			grad = shadowCtx.createRadialGradient(x, y, 0, x, y, offsetX);
			grad.addColorStop(0, colour);
			grad.addColorStop(1, '${colour}0');
		}
		dirty = true;
	}

	private function updateCtx(){
		if(!dirty || grad == null){
			return;
		}

		shadowCtx.clearRect(0, 0, shadowCtx.canvas.width, shadowCtx.canvas.height);

		shadowCtx.globalCompositeOperation = "source-over";
		shadowCtx.fillStyle = grad;
		shadowCtx.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);

		shadowCtx.globalCompositeOperation = "destination-out";
		shadowCtx.fillStyle = "#000";
		room.walls.forEachIn(aabb, w->{
			w.drawShadow(shadowCtx, x, y, offsetX);
		});

		dirty = false;
	}

	public function draw(c:CanvasRenderingContext2D) {
		updateCtx();
		c.drawImage(shadowCtx.canvas, 0, 0);
	}

	public function drawGlow(c:CanvasRenderingContext2D) {
		updateCtx();
		c.drawImage(shadowCtx.canvas, 0, 0);
	}
}