package bsp;

import math.AABB;

class QuadMember<T> extends AABB{
	public var lastForEachRun:Int = 0;
	public var member(default, null):T;

	public function new(member:T, x:Float, y:Float, w:Float, h:Float){
		super(x, y, w, h);
		this.member = member;
	}
}