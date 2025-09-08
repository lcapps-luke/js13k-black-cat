package;

@:native("Snd")
class Sound {
	@:native("c")
	public static function click(){
		ZzFX.zzfx(1,.05,323,.1,0,.06,0,2.4,-62,0,-114,0,.04,.9,51,0,0,.75,0,0,-1170);
	}

	//frq: 74 - 390
	@:native("m")
	public static function mew(frq:Float, vol:Float){
		ZzFX.zzfx(vol,.2,594,.07,0,.35,3,1.2,0,-1,90,.05,0,.2,0,0,0,.51,.16,.07,795);
	}

	@:native("s")
	public static function step(){
		ZzFX.zzfx(1,.05,524.25,0,0,0,2,0,-0.1,-0.2,0,0,0,.1,-2,.9,.02,.7,.02,.04,0);
	}

	@:native("k")
	public static function knock(){
		ZzFX.zzfx(1,.05,261.6256,0,.03,.02,0,1.5,0,0,0,0,0,0,6,0,0,.51,.01,.45,-1394);
	}

	@:native("r")
	public static function crack(){
		ZzFX.zzfx(1,.05,364,.02,.1,.01,4,2.3,0,1,0,0,0,2,49,.1,.03,.72,.02,0,249);
	}

	@:native("a")
	public static function smash(){
		ZzFX.zzfx(1.5,.05,100,.02,0,.06,4,1.5,0,0,50,0,0,0,0,0,.05,.74,.2,0,-3e3);
	}

	@:native("e")
	public static function select(){
		ZzFX.zzfx(1.2,.05,536,.1,.05,.01,0,.2,4,-5,0,0,0,0,265,.1,.4,.85,0,0,-1112);
	}

	@:native("n")
	public static function nav(){
		ZzFX.zzfx(2.4,.05,336,.02,.03,.02,0,1,0,0,-261,.41,0,0,140,0,0,.74,0,0,295);
	}

	@:native("d")
	public static function die(){
		ZzFX.zzfx(2.2,.05,27,0,0,.006,2,2.6,-2,-40,0,0,0,0,0,.7,.45,.82,.21,0,0);
	}
}