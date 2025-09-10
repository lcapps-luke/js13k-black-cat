![Black Cat Maze](assets/logo%20800x500.png "Black Cat Maze")
[Made for JS13K 2025](https://js13kgames.com/)

Navigate the darkness of the Black Cat Maze and escape before your luck runs out.
## Controls
### Desktop
**Move** - arrows / WASD  
**Interact** - space / enter / E

### Gamepad
**Move** - arrows / analog stick   
**Interact** - face buttons

### Mobile
**Move** - on-screen direction buttons  
**Interact** - on-screen Action button

## Building
#### requirements
- [Haxe](https://haxe.org/)
- [7-zip](https://www.7-zip.org/)
- [npm](https://www.npmjs.com/)
	- [svgo](https://www.npmjs.com/package/svgo)
	- [uglifyjs](https://www.npmjs.com/package/uglify-js)
	- [html-minifier](https://www.npmjs.com/package/html-minifier)
	- [roadroller](https://www.npmjs.com/package/roadroller) (optional)

The `ROADROLLER` flag may be provided to compress using roadroller.  
e.g.   
`haxe build.hxml -D ROADROLLER`
