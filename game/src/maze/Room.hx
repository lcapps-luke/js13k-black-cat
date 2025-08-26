package maze;

import math.Vec2;
import math.Random;
import resource.ResourceBuilder;
import js.html.CanvasRenderingContext2D;
import js.Browser;
import js.html.CanvasElement;
import math.AABB;
import bsp.Bsp;

using ui.ContextUtils;

class Room extends AbstractScreen{
	public static inline var CELL_SIZE = 16;
	public static inline var FLICKER_TIME = 3;
	public static inline var LUCK_BAR_WIDTH = Main.WIDTH * 0.5;
	public static inline var LUCK_BAR_HEIGHT = LUCK_BAR_WIDTH * 0.1;

	public var walls(default, null):Bsp<Wall>;
	public var camera(default, null):AABB;

	private var lights:Bsp<Light>;
	public var shadowCanvas:CanvasRenderingContext2D;

	public var player:Player;
	public var playerLight:Light;
	public var playerLightOffset = new Vec2();
	public var playerLightFlickerTimer = FLICKER_TIME;

	private var lvl = ResourceBuilder.buildMap("assets/level/01.tmj");

	public var luck:Float = 100;

	public function new(){
		super();
		var mapWidth = lvl.w * CELL_SIZE;
		var mapHeight = lvl.h * CELL_SIZE;

		backgroundStyle = "#888";
		walls = new Bsp<Wall>(mapWidth, mapHeight, 10);

		var nx = 0;
		var ny = 0;
		for(c in lvl.walls.split("")){
			if(c == "w"){
				var w = new Wall(this);
				w.x = nx * CELL_SIZE;
				w.y = ny * CELL_SIZE;
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

		playerLight = new Light(this, 48, "#FFA700FF");

		lights = new Bsp<Light>(mapWidth, mapHeight, 10);
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
		player.update(s);
		camera.x = Math.max(0, player.x - camera.w / 2);
		camera.y = Math.max(0, player.y - camera.h / 2);

		Main.context.save();
		Main.context.translate(-camera.x, -camera.y);

		player.draw(Main.context);
		playerLight.x = player.x + playerLightOffset.x;
		playerLight.y = player.y + playerLightOffset.y;
		playerLightFlickerTimer--;
		if(playerLightFlickerTimer <= 0){
			playerLightFlickerTimer = FLICKER_TIME;
			playerLightOffset.set(Random.range(-1, 1), Random.range(-1, 1));
		}

		walls.forEachIn(camera, w->{
			w.update(s);
			w.draw(Main.context);
		});

		shadowCanvas.globalCompositeOperation = "source-over";
		shadowCanvas.fillStyle = "#000";
		shadowCanvas.fillRect(0, 0, Main.WIDTH, Main.HEIGHT);
		shadowCanvas.globalCompositeOperation = "destination-out";

		Main.context.restore();
		Main.context.globalAlpha = 0.5;
		Main.context.globalCompositeOperation = "lighter";

		playerLight.update(s);
		playerLight.draw(shadowCanvas);
		playerLight.drawGlow(Main.context);
		lights.forEachIn(camera, l->{
			l.update(s);
			l.draw(shadowCanvas);
			l.drawGlow(Main.context);
		});
		
		Main.context.globalCompositeOperation = "source-over";
		Main.context.globalAlpha = 0.8;
		Main.context.drawImage(shadowCanvas.canvas, 0, 0);
		Main.context.globalAlpha = 1;

		//draw luck
		luck = Math.max(0, luck);
		Main.context.fillStyle = "#444";
		Main.context.fillRect(Main.WIDTH / 2 - LUCK_BAR_WIDTH / 2, 10, LUCK_BAR_WIDTH, LUCK_BAR_HEIGHT);
		Main.context.fillStyle = "#208";
		Main.context.fillRect(Main.WIDTH / 2 - LUCK_BAR_WIDTH / 2, 10, LUCK_BAR_WIDTH * luck / 100, LUCK_BAR_HEIGHT);
		Main.context.fillStyle = "#fff";
		Main.context.font = "bold 10px sans-serif";
		(cast Main.context).letterSpacing = "3px";
		Main.context.centeredText("Luck", Main.WIDTH / 2 - LUCK_BAR_WIDTH / 2, LUCK_BAR_WIDTH, 10 + LUCK_BAR_HEIGHT * 0.8, true);
	}

	public static function newCanvas():CanvasRenderingContext2D{
		var ele:CanvasElement = Browser.document.createCanvasElement();
		ele.width = Main.WIDTH;
		ele.height = Main.HEIGHT;

		var cc = ele.getContext2d();

		return cc;
	}
}