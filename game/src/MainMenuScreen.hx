package;

import js.Browser;
import maze.Room;
using ui.ContextUtils;

class MainMenuScreen extends AbstractScreen{
	private static inline var ITEM_HEIGHT = 30;

	private var opts = new Array<MenuOption>();
	private var idx:Int = 0;

	public function new(){
		super();

		if(Browser.getLocalStorage()?.getItem(Main.SAVE) != null){
			opts.push({
				name: "Continue",
				act: onContinue
			});
		}

		opts.push({
			name: "Start",
			act: onStart
		});

		Main.context.font = "20px sans-serif";
		var yy = Main.HEIGHT * 0.6 - ((opts.length - 1) * ITEM_HEIGHT) / 2;
		for(o in opts){
			var t = Main.context.measureText(o.name);

			o.x = Main.WIDTH / 2 - t.width / 2;
			o.y = yy;
			o.w = t.width;

			yy += ITEM_HEIGHT;
		}


	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#FFF";
		Main.context.font = "30px sans-serif";
		Main.context.centeredText(Main.TITLE, 0, Main.WIDTH, Main.HEIGHT * 0.25);

		Main.context.font = "20px sans-serif";
		for(o in opts){
			Main.context.fillText(o.name, o.x, o.y);
		}

		Main.context.strokeStyle = "#FFF";
		Main.context.lineWidth = 5;
		var opt = opts[idx];
		Main.context.beginPath();
		Main.context.moveTo(opt.x - 30, opt.y - 7);
		Main.context.lineTo(opt.x - 10, opt.y - 7);
		Main.context.stroke();
		Main.context.beginPath();
		Main.context.moveTo(opt.x + opt.w + 10, opt.y - 7);
		Main.context.lineTo(opt.x + opt.w + 30, opt.y - 7);
		Main.context.stroke();

		if(Ctrl.actionPress){
			opt.act();
			Sound.select();
		}
		if(Ctrl.upPress){
			idx = idx > 0 ? idx - 1 : 0;
			Sound.nav();
		}
		if(Ctrl.downPress){
			idx = idx < (opts.length - 1) ? idx + 1 : (opts.length - 1);
			Sound.nav();
		}
	}

	private function onStart(){
		Browser.getLocalStorage()?.setItem(Main.SAVE, "");
		onContinue();
	}

	private function onContinue(){
		Main.currentScreen = new Room();
	}
}

typedef MenuOption = {
	var name:String;
	var ?x:Float;
	var ?y:Float;
	var ?w:Float;
	var act:Void->Void;
}