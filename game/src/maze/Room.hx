package maze;

import maze.obstacle.Ladder;
import maze.obstacle.CatRegion;
import maze.obstacle.Switch;
import maze.obstacle.Gate;
import maze.obstacle.Checkpoint;
import resource.ObjectIds;
import js.html.CanvasPattern;
import resource.Resources;
import maze.obstacle.CrackObstacle;
import maze.obstacle.AbstractObstacle;
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

	private static var CHECKPOINT:Vec2 = null;

	private var mapWidth:Int;
	private var mapHeight:Int;

	public var walls(default, null):Bsp<Wall>;
	public var camera(default, null):AABB;

	private var lights:Bsp<Light>;
	public var shadowCanvas:CanvasRenderingContext2D;

	public var player:Player;
	public var playerLight:Light;
	public var playerLightOffset = new Vec2();
	public var playerLightFlickerTimer = FLICKER_TIME;

	public var obstacles:Bsp<AbstractObstacle>;

	private var lvl = ResourceBuilder.buildMap("assets/level/01.tmj");

	public var luck:Float = 100;
	private var gameOver:Bool = false;
	private var gameOverScreen:GameOverScreen;

	private var bgPattern:CanvasPattern;
	public var interactionHint:String = "test";

	private var deferredDraws = new List<CanvasRenderingContext2D->Void>();

	public function new(){
		super();
		mapWidth = lvl.w * CELL_SIZE;
		mapHeight = lvl.h * CELL_SIZE;

		backgroundStyle = "#888";
		walls = new Bsp<Wall>(mapWidth, mapHeight, 10);

		var nx = 0;
		var ny = 0;
		for(c in lvl.walls.split("")){
			if(c == "w"){
				var w = new Wall(this,  nx * CELL_SIZE,  ny * CELL_SIZE);
				walls.add(w, w.aabb);
			}

			nx++;
			if(nx >= lvl.w){
				nx = 0;
				ny++;
			}
		}

		player = new Player(this);
		CHECKPOINT = loadCheckpoint();
		player.x = CHECKPOINT == null ? lvl.px : CHECKPOINT.x;
		player.y = CHECKPOINT == null ? lvl.py : CHECKPOINT.y;

		playerLight = new Light(this, 48, "#FFA700FF", false);

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

		obstacles = new Bsp<AbstractObstacle>(mapWidth, mapHeight, 10);
		loadObjects(lvl.ob);

		camera = new AABB(0, 0, Main.WIDTH, Main.HEIGHT);

		shadowCanvas = newCanvas();

		bgPattern = Main.context.createPattern(Resources.backgroundTile, "repeat");
	}
	
	private function loadObjects(od:Array<Dynamic>) {
		var odit = od.iterator();
		while(odit.hasNext()){
			var ot:String = cast odit.next();
			switch(ot){
				case ObjectIds.CRACK:
					var co = new CrackObstacle(this, 
						cast odit.next(), // x
						cast odit.next(), // y
						cast odit.next(), // w
						cast odit.next()); // h
					obstacles.add(co, co.aabb);
				case ObjectIds.CHECKPOINT:
					var cp = new Checkpoint(this,
						cast odit.next(), // x
						cast odit.next(), // y
						cast odit.next(), // spawnX
						cast odit.next()); // spawnY
					obstacles.add(cp, cp.aabb);
					var cw = cp.makeWall();
					walls.add(cw, cw.aabb);
				case ObjectIds.GATE:
					var g = Gate.makeWalls(this,
						cast odit.next(), // x
						cast odit.next(), // y
						cast odit.next(), // w
						cast odit.next()); // h

					for(m in g){
						walls.add(m, m.aabb);
					}
					var s = new Switch(this, 
						cast odit.next(), // x
						cast odit.next()); // y
					s.walls = g;
					walls.add(s, s.aabb);
				case ObjectIds.CAT:
					var cr = new CatRegion(this,
						cast odit.next(), // x
						cast odit.next(), // y
						cast odit.next(), // rx
						cast odit.next(), // ry
						cast odit.next(), // rw
						cast odit.next()); // rh
					obstacles.add(cr, cr.aabb);
				case ObjectIds.LADDER:
					var l = new Ladder(this,
						cast odit.next(), // x
						cast odit.next(), // y
						cast odit.next(), // w
						cast odit.next()); // h
					obstacles.add(l, l.aabb);
				default:
					throw "Unknown obstacle type: " + ot;
			}
		}
	}

	override function update(s:Float) {
		super.update(s);
		if(!gameOver){
			player.update(s);
		}
		camera.x = Math.max(0, player.x - camera.w / 2);
		camera.y = Math.max(0, player.y - camera.h / 2);

		Main.context.save();
		Main.context.translate(-camera.x, -camera.y);

		Main.context.fillStyle = bgPattern;
		Main.context.fillRect(camera.x, camera.y, camera.w, camera.h);

		obstacles.forEachIn(camera, o->{
			o.update(s);
			var dd = o.draw(Main.context);
			if(dd != null){
				deferredDraws.add(dd);
			}
		});

		player.draw(Main.context);
		playerLight.x = player.x + playerLightOffset.x;
		playerLight.y = player.y + playerLightOffset.y;
		playerLightFlickerTimer--;
		if(playerLightFlickerTimer <= 0){
			playerLightFlickerTimer = FLICKER_TIME;
			playerLightOffset.set(Random.range(-1, 1), Random.range(-1, 1));
		}

		for(d in deferredDraws){
			d(Main.context);
		}
		deferredDraws.clear();

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
		Main.context.globalAlpha = 1;
		Main.context.drawImage(shadowCanvas.canvas, 0, 0);

		Main.context.fillStyle = "#fff";
		Main.context.font = "bold 10px sans-serif";
		Main.context.centeredText(interactionHint, player.x - camera.x, 0, player.y - camera.y - 10);
		interactionHint = "";

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

		// Draw game over screen if needed
		if(gameOver){
			gameOverScreen.update(s);
		}
	}

	public function hurt(qty:Float):Bool{
		if(luck > 0){
			luck -= qty;
			return false;
		}
		gameOver = true;
		gameOverScreen = new GameOverScreen();
		return true;
	}

	public static function newCanvas():CanvasRenderingContext2D{
		var ele:CanvasElement = Browser.document.createCanvasElement();
		ele.width = Main.WIDTH;
		ele.height = Main.HEIGHT;

		var cc = ele.getContext2d();

		return cc;
	}

	public function saveCheckpoint(x:Float, y:Float) {
		CHECKPOINT = new Vec2(x, y);
		Browser.getLocalStorage()?.setItem("lcann.bcm.chkpt", x + "," + y);
		luck = 100;
	}

	public static function loadCheckpoint():Vec2{
		var data = Browser.getLocalStorage()?.getItem("lcann.bcm.chkpt");
		if(data != null){
			var pos = data.split(",");
			return new Vec2(Std.parseFloat(pos[0]), Std.parseFloat(pos[1]));
		}
		return null;
	}
}