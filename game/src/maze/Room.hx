package maze;

import resource.ResourceBuilder;
import js.html.CanvasRenderingContext2D;
import js.Browser;
import js.html.CanvasElement;
import math.AABB;
import bsp.Bsp;

class Room extends AbstractScreen{
	public var walls(default, null):Bsp<Wall>;
	public var camera(default, null):AABB;

	private var lights:Bsp<Light>;
	public var shadowCanvas:CanvasRenderingContext2D;

	public var player:Player;

	private var lvl = ResourceBuilder.buildMap("assets/level/01.tmj");

	public function new(){
		super();
		backgroundStyle = "#888";
		walls = new Bsp<Wall>(Main.WIDTH, Main.HEIGHT, 10);

		var nx = 0;
		var ny = 0;
		for(c in lvl.walls.split("")){
			if(c == "w"){
				var w = new Wall(this);
				w.x = nx * 32;
				w.y = ny * 32;
				walls.add(w, w.aabb);
			}

			nx++;
			if(nx >= lvl.w){
				nx = 0;
				ny++;
			}
		}

		

		player = new Player(this);
		player.x = lvl.px;
		player.y = lvl.py;

		lights = new Bsp<Light>(Main.WIDTH, Main.HEIGHT, 10);
		var lightQty:Int = Math.floor(lvl.lights.length / 4);
		for(i in 0...lightQty){
			var x:Int = lvl.lights[i * 4];
			var y:Int = lvl.lights[i * 4 + 1];
			var radius:Int = lvl.lights[i * 4 + 2];
			var color:String = lvl.lights[i * 4 + 3];
			var light = new Light(this, radius, color);
			light.x = x;
			light.y = y;
			lights.add(light, light.aabb);
		}

		camera = new AABB(0, 0, Main.WIDTH, Main.HEIGHT);

		shadowCanvas = newCanvas();
	}

	override function update(s:Float) {
		super.update(s);

		walls.forEachIn(camera, w->{
			w.update(s);
			w.draw(Main.context);
		});

		player.update(s);
		player.draw(Main.context);

		shadowCanvas.globalCompositeOperation = "source-over";
		shadowCanvas.fillStyle = "#000";
		shadowCanvas.fillRect(0, 0, Main.WIDTH, Main.HEIGHT);
		shadowCanvas.globalCompositeOperation = "destination-out";
		Main.context.globalAlpha = 0.5;
		Main.context.globalCompositeOperation = "lighter";

		lights.forEachIn(camera, l->{
			l.update(s);
			l.draw(shadowCanvas);
			l.drawGlow(Main.context);
		});

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