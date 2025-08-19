package;

import maze.Room;
using ui.ContextUtils;

class MainMenuScreen extends AbstractScreen{

	public function new(){
		super();
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#FFF";
		Main.context.font = "100px sans-serif";
		Main.context.centeredText(Main.TITLE, 0, Main.WIDTH, Main.HEIGHT * 0.25);

		Main.currentScreen = new Room();
	}
}