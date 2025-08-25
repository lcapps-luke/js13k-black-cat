package math;

class Random {
	public static function range(min:Float, max:Float):Float {
		return Math.random() * (max - min) + min;
	}
}