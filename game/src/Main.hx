package;

import resource.Resources;
import js.html.DivElement;
import js.Browser;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;

class Main{
	public static inline var WIDTH = 255;
	public static inline var HEIGHT = 255;
	public static var TITLE = "Black Cat";

	@:native("ca")
	public static var canvas(default, null):CanvasElement;

	@:native("c")
	public static var context(default, null):CanvasRenderingContext2D;

	@:native("cs")
	public static var currentScreen:AbstractScreen;

	@:native("l")
	public static var lastFrame:Float = 0;

	private static var oscL:DivElement;
	private static var oscR:DivElement;

	public static function main(){
		canvas = cast Browser.document.getElementById("c");
		context = canvas.getContext2d();

		oscL = cast Browser.document.querySelector(".osc.left");
		oscR = cast Browser.document.querySelector(".osc.right");

		Browser.window.onresize = onResize;
		onResize();

		Ctrl.init(Browser.window, canvas);

		currentScreen = new LoadingScreen();

		Browser.window.requestAnimationFrame(update);
	}

	private static function update(s:Float){
		var d = s - lastFrame;

		Ctrl.update();

		currentScreen?.update(d / 1000);

		lastFrame = s;
		Browser.window.requestAnimationFrame(update);
	}

	private static function onResize(){
		var w = Browser.window.innerWidth;
		var h = Browser.window.innerHeight;

		var cl = (w - canvas.clientWidth) / 2;
		canvas.style.top = '0px';
		canvas.style.left = '${cl}px';

		if(h > w){
			var ctrlHeight = h - canvas.clientHeight;
			var btm = Math.max(0, ctrlHeight / 2 - w / 4);

			oscL.style.width = '${w / 2}px';
			oscL.style.height = '${w / 2}px';
			oscL.style.bottom = '${btm}px';
			oscL.style.top = null;
			oscL.style.left = '0px';

			oscR.style.width = '${w / 2}px';
			oscR.style.height = '${w / 2}px';
			oscR.style.bottom = '${btm}px';
			oscR.style.top = null;
			oscR.style.right = '0px';
		}else{
			var sz = Math.min(h, cl);

			oscL.style.width = '${sz}px';
			oscL.style.height = '${sz}px';
			oscL.style.top = '${h / 2 - sz / 2}px';
			oscL.style.left = '0px';

			oscR.style.width = '${sz}px';
			oscR.style.height = '${sz}px';
			oscR.style.top = '${h / 2 - sz / 2}px';
			oscR.style.right = '0px';
		}
	}
}