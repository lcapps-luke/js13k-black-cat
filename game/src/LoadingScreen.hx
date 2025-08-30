package;

import resource.Resources;
using ui.ContextUtils;

class LoadingScreen extends AbstractScreen{

	public function new(){
		super();

		Resources.load().then((i) -> {
			Main.currentScreen = new MainMenuScreen();
		});
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#FFF";
		Main.context.font = "20px sans-serif";
		Main.context.centeredText('Loading (${Resources.loadedQty} / ${Resources.resourceQty})', 0, Main.WIDTH, Main.HEIGHT * 0.5);
	}
}