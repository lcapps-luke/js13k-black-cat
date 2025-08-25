package resource;

#if macro
	import haxe.io.Path;
	import sys.io.File;
	import sys.FileSystem;
	import haxe.macro.Context;
	import haxe.Json;
#end

class ResourceBuilder {
	private static inline var SCALE = 0.5;

	public static macro function buildMap(mapFilePath:String){

		var mapData:TiledMap = Json.parse(File.getContent(mapFilePath));
		var walls:String = "";
		var width:Int;
		var height:Int;
		var objects:MapObjects;
		
		for(l in mapData.layers){
			if(l.type == "tilelayer"){
				walls = loadWalls(l);
				width = l.width;
				height = l.height;
			}else if(l.type == "objectgroup"){
				objects = loadObjects(l);
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

			public function new() {}
		}

		Context.defineType(c);

		return macro new R();
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

	private static function loadObjects(l:TiledLayer):MapObjects{
		var obj:MapObjects = {
			playerX: 0,
			playerY: 0,
			lights: []
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
}