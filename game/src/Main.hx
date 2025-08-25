package;

import js.Browser;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;

class Main{
	public static inline var WIDTH = 255;//544;
	public static inline var HEIGHT = 255;//544;
	public static var TITLE = "Black Cat";

	@:native("ca")
	public static var canvas(default, null):CanvasElement;

	@:native("c")
	public static var context(default, null):CanvasRenderingContext2D;

	@:native("cs")
	public static var currentScreen:AbstractScreen;

	@:native("l")
	public static var lastFrame:Float = 0;

	public static function main(){
		canvas = cast Browser.document.getElementById("c");
		context = canvas.getContext2d();

		Browser.window.onresize = onResize;
		onResize();

		Ctrl.init(Browser.window, canvas);

		currentScreen = new MainMenuScreen();

		Browser.window.requestAnimationFrame(update);
	}

	private static function update(s:Float){
		var d = s - lastFrame;

		Ctrl.update();

		currentScreen?.update(d / 1000);

		Ctrl.reset();
		Ctrl.draw();
		
		lastFrame = s;
		Browser.window.requestAnimationFrame(update);
	}

	private static function onResize(){
		var w = Browser.window.innerWidth;
		var h = Browser.window.innerHeight;

		canvas.style.top = '${(h - canvas.clientHeight) / 2}px';
		canvas.style.left = '${(w - canvas.clientWidth) / 2}px';
	}
}