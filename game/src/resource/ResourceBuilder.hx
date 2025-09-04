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
				objects = loadObjects(l, objects, mapData);
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

	private static function loadObjects(l:TiledLayer, current:MapObjects, mapData:TiledMap):MapObjects{
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
				case "Checkpoint":
					makeCheckpoint(o, obj.obstacles, mapData);
				case "Gate":
					makeGate(o, obj.obstacles, mapData);
				case "Cat":
					makeCat(o, obj.obstacles, mapData);
				case "Ladder":
					makeLadder(o, obj.obstacles);
				case "Mirror":
					makeMirror(o, obj.obstacles);
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

	private static function getProperty(props:Array<TiledProperty>, name:String):String{
		for(p in props){
			if(p.name == name){
				return Std.string(p.value);
			}
		}
		throw 'No ${name} property found';
	}

	private static function getDirectionPropOffset(props:Array<TiledProperty>):Array<Int>{
		var dir = getProperty(props, "direction");
		return switch(dir){
			case "UP": [0, -4];
			case "DOWN": [0, 4];
			case "LEFT": [-4, 0];
			case "RIGHT": [4, 0];
			default: throw 'Unknown direction value: ${dir}';
		}
	}

	private static function argbTorgba(argb:String):String{
		var a = argb.substr(1, 2);
		var r = argb.substr(3, 2);
		var g = argb.substr(5, 2);
		var b = argb.substr(7, 2);
		return '#$r$g$b$a';
	}

	private static function cleanDir(dir) {
		for (f in FileSystem.readDirectory(dir)) {
			if (!FileSystem.isDirectory(dir + f)) {
				FileSystem.deleteFile(dir + f);
			}
		}
	}

	private static function findObject(mapData:TiledMap, id:Int):TiledObject {
		for(layer in mapData.layers) {
			if(layer.type != "objectgroup"){
				continue;
			}

			for(obj in layer.objects) {
				if(obj.id == id) {
					return obj;
				}
			}
		}
		throw "Object not found: " + id;
	}

	private static function makeCrackObstacle(o:TiledObject, arr:Array<Dynamic>):Void{
		arr.push(ObjectIds.CRACK);
		arr.push(o.x * SCALE);
		arr.push(o.y * SCALE);
		arr.push(o.width * SCALE);
		arr.push(o.height * SCALE);
	}

	private static function makeCheckpoint(o:TiledObject, arr:Array<Dynamic>, mapData:TiledMap):Void{
		var spawnObjId = Std.parseInt(getProperty(o.properties, "spawn"));
		var spawnObj = findObject(mapData, spawnObjId);

		arr.push(ObjectIds.CHECKPOINT);
		arr.push(Math.round((o.x + o.width / 2) * SCALE));
		arr.push(Math.round((o.y + o.height / 2) * SCALE));
		arr.push(Math.round(spawnObj.x * SCALE));
		arr.push(Math.round(spawnObj.y * SCALE));
	}

	private static function makeGate(o:TiledObject, arr:Array<Dynamic>, mapData:TiledMap):Void{
		var switchObjId = Std.parseInt(getProperty(o.properties, "switch"));
		var switchObj = findObject(mapData, switchObjId);

		arr.push(ObjectIds.GATE);
		arr.push(o.x * SCALE);
		arr.push(o.y * SCALE);
		arr.push(o.width * SCALE);
		arr.push(o.height * SCALE);
		arr.push(switchObj.x * SCALE);
		arr.push(switchObj.y * SCALE);
	}

	private static function makeCat(o:TiledObject, arr:Array<Dynamic>, mapData:TiledMap):Void{
		var regionObjId = Std.parseInt(getProperty(o.properties, "region"));
		var regionObj = findObject(mapData, regionObjId);

		arr.push(ObjectIds.CAT);
		arr.push(o.x * SCALE);
		arr.push(o.y * SCALE);
		arr.push(regionObj.x * SCALE);
		arr.push(regionObj.y * SCALE);
		arr.push(regionObj.width * SCALE);
		arr.push(regionObj.height * SCALE);
	}

	private static function makeLadder(o:TiledObject, arr:Array<Dynamic>):Void{
		arr.push(ObjectIds.LADDER);
		arr.push(o.x * SCALE);
		arr.push(o.y * SCALE);
		arr.push(o.width * SCALE);
		arr.push(o.height * SCALE);
	}

	private static function makeMirror(o:TiledObject, arr:Array<Dynamic>):Void{
		arr.push(ObjectIds.MIRROR);
		arr.push(o.x * SCALE);
		arr.push(o.y * SCALE);
		arr.push(o.width * SCALE);
		arr.push(o.height * SCALE);
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
	var id:Int;
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