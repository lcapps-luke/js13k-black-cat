package bsp;

import math.AABB;

class Bsp<T>{
	private var thisForEachRun:Int = 0;
	private var quads:List<Quad<T>>;

	public function new(width:Float, height:Float, divisions:Int){
		var qw = width / divisions;
		var qh = height / divisions;

		quads = new List<Quad<T>>();
		for(w in 0...divisions){
			for(h in 0...divisions){
				quads.push(new Quad(w * qw, h * qh, qw, qh));
			}
		}
	}

	public function add(member:T, aabb:AABB){
		var m = new QuadMember(member, aabb.x, aabb.y, aabb.w, aabb.h);
		for(q in quads){
			if(q.overlaps(aabb)){
				q.add(m);
			}
		}
	}

	public function forEachIn(aabb:AABB, callback:T->Void){
		thisForEachRun++;
		for(q in quads){
			if(q.overlaps(aabb)){
				q.forEachIn(aabb, thisForEachRun, callback);
			}
		}
	}
}