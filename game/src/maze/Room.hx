package maze;

import ui.Pointer;
import js.html.svg.Point;
import js.html.CanvasRenderingContext2D;
import js.Browser;
import js.html.CanvasElement;
import math.AABB;
import bsp.Bsp;

class Room extends AbstractScreen{
	public var walls(default, null):Bsp<Wall>;
	public var camera(default, null):AABB;

	public var lighta:Light;
	public var lightb:Light;
	public var shadowCanvas:CanvasRenderingContext2D;

	public function new(){
		super();
		backgroundStyle = "#888";
		walls = new Bsp<Wall>(Main.WIDTH, Main.HEIGHT, 2);
		
		var w = new Wall(this);
		w.x = 900;
		w.y = 720;
		walls.add(w, w.aabb);

		lighta = new Light(this, 402, "#0F0");
		lighta.x = 725;
		lighta.y = 628;
		lightb = new Light(this, 402, "#00F");
		lightb.x = 1106;
		lightb.y = 628;

		camera = new AABB(0, 0, Main.WIDTH, Main.HEIGHT);

		shadowCanvas = newCanvas();
	}

	override function update(s:Float) {
		super.update(s);

		walls.forEachIn(camera, w->{
			w.update(s);
			w.draw(Main.context);
		});

		lightb.x = Pointer.X;
		lightb.y = Pointer.Y;

		lighta.update(s);
		lightb.update(s);

		

		shadowCanvas.globalCompositeOperation = "source-over";
		shadowCanvas.fillStyle = "#000";
		shadowCanvas.fillRect(0, 0, Main.WIDTH, Main.HEIGHT);
		shadowCanvas.globalCompositeOperation = "destination-out";
		lighta.draw(shadowCanvas);
		lightb.draw(shadowCanvas);

		Main.context.globalAlpha = 0.5;
		Main.context.globalCompositeOperation = "lighter";
		lighta.drawGlow(Main.context);
		lightb.drawGlow(Main.context);
		Main.context.globalCompositeOperation = "source-over";

		Main.context.globalAlpha = 0.8;
		Main.context.drawImage(shadowCanvas.canvas, 0, 0);
		Main.context.globalAlpha = 1;
	}

	public static function newCanvas():CanvasRenderingContext2D{
		var ele:CanvasElement = Browser.document.createCanvasElement();
		ele.width = Main.WIDTH;
		ele.height = Main.HEIGHT;

		var cc = ele.getContext2d();

		return cc;
	}
}