package resource;

#if macro
import haxe.Json;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
#end

class ResourceBuilder {
	private static inline var SCALE = 0.5;

	private static inline var IMG_PATH = "assets/images";
	private static inline var IMG_MIN_PATH = "build/assets/images/";
	private static var minifiedImages = false;

	public static macro function buildMap(mapFilePath:String){

		var mapData:TiledMap = Json.parse(File.getContent(mapFilePath));
		var walls:String = "";
		var width:Int;
		var height:Int;
		var objects:MapObjects = null;
		
		for(l in mapData.layers){
			if(l.type == "tilelayer"){
				walls = loadWalls(l);
				width = l.width;
				height = l.height;
			}else if(l.type == "objectgroup"){
				objects = loadObjects(l, objects);
			}
		}

		// Construct resource type
		var c = macro class R {
			public var walls:String = $v{walls};
			public var w:Int = $v{width};
			public var h:Int = $v{height};
			public var px:Int = $v{objects.playerX};
			public var py:Int = $v{objects.playerY};
			public var lights:Array<Dynamic> = $v{objects.lights};
			public var ob:Array<Dynamic> = $v{objects.obstacles};

			public function new() {}
		}

		Context.defineType(c);

		return macro new R();
	}

	macro public static function buildImage(name:String):ExprOf<String> {
		if (!minifiedImages) {
			FileSystem.createDirectory(IMG_MIN_PATH);
			cleanDir(IMG_MIN_PATH);

			Sys.command("svgo", [
				      "-f",              IMG_PATH,
				      "-o",          IMG_MIN_PATH,
				      "-p",                   "1",
				"--enable",         "removeTitle",
				"--enable",          "removeDesc",
				"--enable",   "removeUselessDefs",
				"--enable", "removeEditorsNSData",
				"--enable",       "removeViewBox",
				"--enable", "transformsWithOnePath"
			]);

			minifiedImages = true;
		}

		var imgContent = File.getContent(IMG_MIN_PATH + name);

		return Context.makeExpr(imgContent, Context.currentPos());
	}

	#if macro
	private static function loadWalls(l:TiledLayer):String{
		return l.data.map(id -> {
			return switch(id){
				case 0: "f";
				case 1: "w";
				default: "z";
			}
		}).join("");
	}

	private static function loadObjects(l:TiledLayer, current:MapObjects):MapObjects{
		var obj:MapObjects = current != null ? current : {
			playerX: 0,
			playerY: 0,
			lights: [],
			obstacles: []
		};

		var lightQty = 0;

		for(o in l.objects){
			switch(o.type){
				case "Player":
					obj.playerX = Math.round((o.x + o.width / 2) * SCALE);
					obj.playerY = Math.round((o.y + o.height / 2) * SCALE);
				case "Light":
					lightQty++;

					var offset = getDirectionPropOffset(o.properties);

					var x = Math.round((o.x + o.width / 2) * SCALE) + offset[0];
					var y = Math.round((o.y + o.height / 2) * SCALE) + offset[1];
					var r = Math.round(o.width / 2 * SCALE);
					var c = getColourProp(o.properties);

					obj.lights.push(x); // x,y,r,c
					obj.lights.push(y);
					obj.lights.push(r);
					obj.lights.push(c);
				case "Crack":
					makeCrackObstacle(o, obj.obstacles);
			}
		}

		return obj;
	}

	private static function getColourProp(props:Array<TiledProperty>):String{
		for(p in props){
			if(p.name == "colour"){
				return argbTorgba(p.value);
			}
		}
		throw "No colour property found";
	}

	private static function getDirectionPropOffset(props:Array<TiledProperty>):Array<Int>{
		for(p in props){
			if(p.name == "direction"){
				return switch(p.value){
					case "UP": [0, -4];
					case "DOWN": [0, 4];
					case "LEFT": [-4, 0];
					case "RIGHT": [4, 0];
					default: throw 'Unknown direction value: ${p.value}';
				}
			}
		}
		throw "No direction property found";
	}

	private static function argbTorgba(argb:String):String{
		var a = argb.substr(1, 2);
		var r = argb.substr(3, 2);
		var g = argb.substr(5, 2);
		var b = argb.substr(7, 2);
		return '#$r$g$b$a';
	}

	private static function makeCrackObstacle(o:TiledObject, arr:Array<Dynamic>):Void{
		arr.push("c");
		arr.push(o.x * SCALE);
		arr.push(o.y * SCALE);
		arr.push(o.width * SCALE);
		arr.push(o.height * SCALE);
	}

	private static function cleanDir(dir) {
		for (f in FileSystem.readDirectory(dir)) {
			if (!FileSystem.isDirectory(dir + f)) {
				FileSystem.deleteFile(dir + f);
			}
		}
	}

	#end
}

typedef TiledMap = {
	var layers:Array<TiledLayer>;
	var properties:Array<TiledProperty>;
	var tilewidth:Int;
	var tileheight:Int;
}

typedef TiledLayer = {
	var name:String;
	var objects:Array<TiledObject>;
	var data:Array<Int>;
	var type:String;
	var width:Int;
	var height:Int;
}

typedef TiledObject = {
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
	var type:String;
	var properties:Array<TiledProperty>;
}

typedef TiledProperty = {
	var name:String;
	var type:String;
	var value:String;
}

typedef MapObjects = {
	var playerX:Int;
	var playerY:Int;
	var lights:Array<Dynamic>; //qty{x,y,r,c}
	var obstacles:Array<Dynamic>;
}