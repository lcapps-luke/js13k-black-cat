package maze;

import js.html.CanvasGradient;
import js.html.CanvasRenderingContext2D;
using ui.ContextUtils;

class Light extends AbstractEntity{
	private static var shadowCtx:CanvasRenderingContext2D = Room.newCanvas();
	private var grad:CanvasGradient;

	private var lastX:Float = null;
	private var lastY:Float = null;
	
	private var colour:String;
	private var dirty = true;

	private var castPlayer:Bool;

	public function new(room:Room, radius:Float, colour:String, castPlayer:Bool = true){
		super(room);
		aabb.w = radius * 2;
		aabb.h = radius * 2;
		offset.set(radius, radius);

		this.colour = colour;
		this.castPlayer = castPlayer;
	}

	public function update(s:Float) {
		if(lastX == null || lastY == null || lastX != x || lastY != y){
			grad = shadowCtx.createRadialGradient(x, y, 0, x, y, offset.x);
			grad.addColorStop(0, colour);
			grad.addColorStop(1, colour.substr(0, 7) + "00");
		}
		dirty = true;
	}

	private function updateCtx(){
		if(!dirty || grad == null){
			return;
		}

		shadowCtx.clearRect(0, 0, shadowCtx.canvas.width, shadowCtx.canvas.height);

		shadowCtx.save();
		shadowCtx.translate(-room.camera.x, -room.camera.y);

		shadowCtx.globalCompositeOperation = "source-over";
		shadowCtx.fillStyle = grad;
		shadowCtx.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);

		shadowCtx.globalCompositeOperation = "destination-out";
		shadowCtx.fillStyle = "#000";
		room.walls.forEachIn(aabb, w->{
			w.drawShadow(shadowCtx, x, y, offset.x);
		});

		if(castPlayer){
			room.obstacles.forEachIn(aabb, o->{
				o.drawShadow(shadowCtx, x, y, offset.x);
			});

			if(aabb.overlaps(room.player.aabb)){
				room.player.drawShadow(shadowCtx, x, y, offset.x);
			}
		}

		dirty = false;

		shadowCtx.restore();
	}

	public function draw(c:CanvasRenderingContext2D):CanvasRenderingContext2D->Void {
		updateCtx();
		c.drawImage(shadowCtx.canvas, 0, 0);
		return null;
	}

	public function drawGlow(c:CanvasRenderingContext2D) {
		updateCtx();
		c.drawImage(shadowCtx.canvas, 0, 0);
	}
}