package resource;

import js.html.ImageElement;
import js.Browser;
import js.html.CanvasElement;
import js.lib.Promise;

@:native("Res")
class Resources {
	
	public static inline var CRACK = "c";
	public static inline var PLAYER = "p";
	public static inline var PLANTER = "l";
	public static inline var BRANCHES = "b";
	public static inline var SWITCH = "s";
	public static inline var CAT = "a";
	public static inline var MIRROR = "m";
	public static inline var PLAYER_FALL = "f";
	public static inline var MIRROR_SMASH = "i";

	@:native("rq")
	public static var resourceQty:Int = 0;
	@:native("lq")
	public static var loadedQty:Int = 0;

	@:native("bg")
	public static var backgroundTile:ImageElement;

	@:native("i")
	public static var images:Map<String, ImageElement> = new Map();

	@:native("l")
	public static function load() {
		var loaders = [
			loadBackgroundTile,
			() -> loadImage(CRACK, ResourceBuilder.buildImage("crack.svg")),
			() -> loadImage(PLAYER, ResourceBuilder.buildImage("player.svg")),
			() -> loadImage(PLANTER, ResourceBuilder.buildImage("planter.svg")),
			() -> loadImage(BRANCHES, ResourceBuilder.buildImage("branches.svg")),
			() -> loadImage(SWITCH, ResourceBuilder.buildImage("switch.svg")),
			() -> loadImage(CAT, ResourceBuilder.buildImage("cat.svg")),
			() -> loadImage(MIRROR, ResourceBuilder.buildImage("mirror.svg")),
			() -> loadImage(PLAYER_FALL, ResourceBuilder.buildImage("player_fall.svg")),
			() -> loadImage(MIRROR_SMASH, ResourceBuilder.buildImage("mirror_smash.svg"))
		];

		resourceQty = loaders.length;

		var p = Promise.resolve();

		for (l in loaders) {
			p = p.then((a) -> {
				loadedQty++;
				return l();
			});
		}

		return p;
	}

	@:native("lbt")
	private static function loadBackgroundTile():Promise<Int> {
		var sz = 24;
		return new Promise((resolve, reject) -> {
			var ele:CanvasElement = Browser.document.createCanvasElement();
			ele.width = sz;
			ele.height = sz;
			var cc = ele.getContext2d();
			cc.fillStyle = "#888";
			cc.fillRect(0, 0, sz, sz);

			cc.lineWidth = 1;
			cc.strokeStyle = "#444";
			cc.beginPath();
			cc.rect(0, 0, sz, sz);
			cc.stroke();
			cc.lineWidth = 1;
			cc.beginPath();
			cc.strokeStyle = "#666";
			cc.rect(2, 2, sz - 4, sz - 4);
			cc.stroke();

			backgroundTile = Browser.document.createImageElement();
			backgroundTile.src = ele.toDataURL();
			backgroundTile.onload = () -> {
				resolve(1);
			};
			backgroundTile.onerror = (e) -> {
				reject(e);
			};
		});
	}

	private static function loadImage(name:String, data:String):Promise<Int> {
		return new Promise((resolve, reject) -> {
			var d = "data:image/svg+xml;base64," + Browser.window.btoa(data);
			var i:ImageElement = Browser.document.createImageElement();
			i.onload = () -> {
				images.set(name, i);
				resolve(1);
			};
			i.onerror = function(e) {
				reject(e);
			}
			i.setAttribute("src", d);
		});
	}
}
