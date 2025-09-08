using ui.ContextUtils;

class GameCompleteScreen extends AbstractScreen{
	private static inline var BG_ALPHA = 0.7;
	private static inline var FADE_TIME = 1;

	private var bgAlpha:Float = 0;
	private var fgAlpha:Float = 0;

	public function new(){
		super();
	}

	override public function update(s:Float){
		Main.context.globalAlpha = bgAlpha * BG_ALPHA;
		super.update(s);
		Main.context.globalAlpha = fgAlpha;

		if(bgAlpha < 1){
			bgAlpha += FADE_TIME * s;
		}else if(fgAlpha < 1){
			fgAlpha += FADE_TIME * s;
		}else{
			if(Ctrl.action){
				Main.currentScreen = new MainMenuScreen();
				Sound.select();
			}
		}

		Main.context.fillStyle = "#FFF";
		Main.context.font = "20px monospace";
		Main.context.centeredText("You escaped", 0, Main.WIDTH, Main.HEIGHT * 0.25);
		Main.context.centeredText("the maze!", 0, Main.WIDTH, Main.HEIGHT * 0.25 + 20);
		Main.context.font = "10px monospace";
		Main.context.centeredText("Press any key to re-start", 0, Main.WIDTH, Main.HEIGHT * 0.5);

		Main.context.globalAlpha = 1;
	}
}