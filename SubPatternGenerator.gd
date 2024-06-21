extends Node2D
const PatternGenerator = preload("res://PatternGenerator.gd")

@export var PATTERN: Node2D
@export var BG: Node2D
@export var SUBVIEWPORT: SubViewport
func _ready():
	#generatePNG(Vector2(128,128),Color("b00404"),"red_background.png")
	#generatePNG(Vector2(128,128),Color("000000"),"black_background.png")
	#generatePNG(Vector2(128,128),Color(0,0,0,0),"transparent_background.png")
	#generatePNG(Vector2(32,32),Color("FFFFFF"),"white.png")
	
	var patterns = {
	0:[true,false,true,false,false,false,true,false,false],
	1:[true,false,false,false,false,false,false,false,true],
	2:[true,false,true,false,false,false,true,false,true],
	3:[true,false,true,false,true,false,true,false,false],
	4:[true,true,true,false,false,false,true,true,true],
	5:[true,false,false,true,true,true,false,false,true],
	6:[true,true,false,false,true,false,true,true,true],
	7:[true,false,true,true,false,true,true,true,true],
	8:[true,false,false,true,false,true,true,true,true],
	9:[true,false,true,false,false,false,true,true,true],
	10:[true,false,true,false,true,true,true,true,true],
	11:[false,false,true,false,true,true,true,true,true],
	12:[true,true,true,false,false,false,true,true,true],
	13:[true,false,false,false,true,false,false,false,true],
	14:[true,true,true,true,false,false,true,false,true],
	15:[true,true,false,true,false,false,false,false,true],
	16:[true,false,true,false,true,false,true,false,true],
	17:[true,false,true,true,false,true,true,false,false],
	18:[true,true,true,true,false,true,true,true,true],
	19:[false,true,true,false,false,true,false,false,true],
	}
	
	#generateSubPatterns(patterns,"input/background/black_background.png","output/subpatterns/black/","subsymbol_*_s")
	#generateSubPatterns(patterns,"input/background/red_background.png","output/subpatterns/red/","subsymbol_*")
	#generateSubPatterns(patterns,"input/background/transparent_background.png","output/subpatterns/transparent/","subsymbol_*")
	for index in patterns.size():
		PatternGenerator.new().generateLargeSymbolJsonFile(index)
	

func generateSubPatterns(patterns: Dictionary,backGroundImage:String,saveDirectory: String, filenames:String):
	BG.texture = load(str("res://",backGroundImage))
	for pattern_key in patterns:
		var pattern = patterns[pattern_key]
		for block in 9:
			PATTERN.get_child(block).visible = pattern[block]
		await RenderingServer.frame_post_draw
		var img = SUBVIEWPORT.get_texture().get_image()
		#img.flip_y()
		#img.flip_x()
		img.save_png(str(saveDirectory,filenames.replace("*",str(pattern_key)),".png"))
	
func generateImage(size:Vector2,color: Color):
	var img = Image.create(size.x,size.y,false,Image.FORMAT_RGBA8)
	img.fill(color)
	return img

func generatePNG(size:Vector2,color: Color, fileName: String):
	var img = Image.create(size.x,size.y,false,Image.FORMAT_RGBA8)
	img.fill(color)
	img.save_png(fileName)
