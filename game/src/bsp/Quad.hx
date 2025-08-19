package bsp;

import math.AABB;

class Quad<T> extends AABB{
	private var members:List<QuadMember<T>>;

	public function new(x:Float, y:Float, w:Float, h:Float){
		super(x, y, w, h);
		members = new List<QuadMember<T>>();
	}

	public function add(m:QuadMember<T>) {
		members.add(m);
	}

	public function forEachIn(aabb:AABB, thisForEachRun:Int, callback:T -> Void) {
		for (m in members) {
			if(m.lastForEachRun != thisForEachRun && m.overlaps(aabb)){
				callback(m.member);
			}
			m.lastForEachRun = thisForEachRun;
		}
	}

	
}