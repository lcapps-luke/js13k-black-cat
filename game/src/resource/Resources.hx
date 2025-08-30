package resource;

import js.html.ImageElement;
import js.Browser;
import js.html.CanvasElement;
import js.lib.Promise;

@:native("Res")
class Resources {
	@:native("rq")
	public static var resourceQty:Int = 0;
	@:native("lq")
	public static var loadedQty:Int = 0;

	@:native("bg")
	public static var backgroundTile:ImageElement;

	@:native("l")
	public static function load(){
		var loaders = [
			loadBackgroundTile
		];

		resourceQty = loaders.length;

		var p = Promise.resolve();

		for(l in loaders){
			p = p.then((a) -> {
				loadedQty++;
				return l();
			});
		}

		return p;
	}

	@:native("lbt")
	private static function loadBackgroundTile():Promise<Int>{
		var sz = 24;
		return new Promise((resolve, reject) -> {
			var ele:CanvasElement = Browser.document.createCanvasElement();
			ele.width = sz;
			ele.height = sz;
			var cc = ele.getContext2d();
			cc.fillStyle = "#888";
			cc.fillRect(0, 0, sz, sz);

			cc.lineWidth = 2;
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
				reject("Failed to load background tile");
			};
		});
	}
}