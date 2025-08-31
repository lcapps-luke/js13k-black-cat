package maze.obstacle;

class Gate {
	private static inline var SIZE = 4;
	private static inline var OFFSET = (Room.CELL_SIZE - SIZE) / 2;

	public static function makeWalls(room:Room, x:Float, y:Float, w:Float, h:Float) {
		var walls:Array<Wall> = [];
		for(wx in 0...Math.floor(w / Room.CELL_SIZE)){
			for(wy in 0...Math.floor(h / Room.CELL_SIZE)){
				walls.push(new Wall(room, x + wx * Room.CELL_SIZE + OFFSET, y + wy * Room.CELL_SIZE + OFFSET, SIZE, SIZE));
			}
		}
		return walls;
	}

}