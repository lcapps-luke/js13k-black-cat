package;

class Sound {
	public static function click(){
		ZzFX.zzfx(1,.05,323,.1,0,.06,0,2.4,-62,0,-114,0,.04,.9,51,0,0,.75,0,0,-1170);
	}

	//frq: 74 - 390
	public static function mew(frq:Float, vol:Float){
		ZzFX.zzfx(vol,.2,594,.07,0,.35,3,1.2,0,-1,90,.05,0,.2,0,0,0,.51,.16,.07,795);
	}

	public static function step(){
		ZzFX.zzfx(1,.05,524.25,0,0,0,2,0,-0.1,-0.2,0,0,0,.1,-2,.9,.02,.7,.02,.04,0);
	}

	public static function knock(){
		ZzFX.zzfx(1,.05,261.6256,0,.03,.02,0,1.5,0,0,0,0,0,0,6,0,0,.51,.01,.45,-1394);
	}

	public static function crack(){
		ZzFX.zzfx(1,.05,364,.02,.1,.01,4,2.3,0,1,0,0,0,2,49,.1,.03,.72,.02,0,249);
	}
}