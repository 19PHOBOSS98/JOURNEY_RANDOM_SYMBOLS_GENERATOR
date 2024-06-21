extends Node2D
@export var SUBVIEWPORT: SubViewport
@export var SUBPATTERN0: Sprite2D
@export var SUBPATTERN1: Sprite2D
@export var SUBPATTERN2: Sprite2D
@export var SUBPATTERN3: Sprite2D
@export var BG: Sprite2D
@export var RED_BG_IMAGE: Resource
@export var BLACK_BG_IMAGE: Resource
@export var FILENAMES: String
@export var TOTAL_PATTERNS: int = 1

var LARGE_SYMBOLS_JSON_IN_PATH = "input/cloth_whale/large_symbols/"
var BIG_SYMBOLS_JSON_IN_PATH = "input/cloth_whale/big_symbols/"
var SMALL_SYMBOLS_JSON_IN_PATH = "input/cloth_whale/small_symbols/"

var LARGE_SYMBOLS_JSON_OUT_PATH = "output/cloth_whale/large_symbols/"
var BIG_SYMBOLS_JSON_OUT_PATH = "output/cloth_whale/big_symbols/"
var SMALL_SYMBOLS_JSON_OUT_PATH = "output/cloth_whale/small_symbols/"

func _ready():
	generatePatterns(TOTAL_PATTERNS,"output/patterns/",FILENAMES)
	generateBlockStateJsonFiles()
	generateSymbolJsonFiles(TOTAL_PATTERNS)

func generatePatterns(totalPatterns:int,saveDirectory: String, filenames:String):
	
	var spriteRange = (SUBPATTERN0.hframes * SUBPATTERN0.vframes) - 1
	
	var angles: Array[int] = [0, 90, 180, 270]
	
	for index in totalPatterns:
		SUBPATTERN0.frame = randi_range(0,spriteRange)
		SUBPATTERN0.rotation_degrees = angles.pick_random()
		SUBPATTERN1.frame = randi_range(0,spriteRange)
		SUBPATTERN1.rotation_degrees = angles.pick_random()
		SUBPATTERN2.frame = randi_range(0,spriteRange)
		SUBPATTERN2.rotation_degrees = angles.pick_random()
		SUBPATTERN3.frame = randi_range(0,spriteRange)
		SUBPATTERN3.rotation_degrees = angles.pick_random()

		BG.texture = load(RED_BG_IMAGE.resource_path)
		await RenderingServer.frame_post_draw
		var img = SUBVIEWPORT.get_texture().get_image()
		img.save_png(str(saveDirectory,"red/",filenames,index,".png"))
		
		BG.texture = load(BLACK_BG_IMAGE.resource_path)
		await RenderingServer.frame_post_draw
		img = SUBVIEWPORT.get_texture().get_image()
		img.save_png(str(saveDirectory,"black/",filenames,index,"_s",".png"))

func generateSymbolJsonFiles(totalPatterns:int):
	for index in totalPatterns:
		generateBigSymbolJsonFile(index)
		generateSmallSymbolJsonFile(index,totalPatterns)


const BLOCKSTATE_TEMPLATE = {
  "variants": {
	"facing=east": [
		{
			"model": "", "weight": 10, "y": 270
		}
	],
	"facing=north": [
		{
			"model": "", "weight": 10, "y": 180
		}
	],
	"facing=south": [
		{
			"model": "", "weight": 10
		}
	],
	"facing=west":  [
		{
			"model": "", "weight": 10, "y": 90
		}
	]
  }
}

const TERRACOTTA_BLACK_MODEL_DIRECTORY = "minecraft:block/cloth_whale/big_symbols/symbol_block_A"
const TERRACOTTA_BROWN_MODEL_DIRECTORY = "minecraft:block/cloth_whale/small_symbols/boarder_2/symbol_block_A"
const TERRACOTTA_CYAN_MODEL_DIRECTORY  = "minecraft:block/cloth_whale/small_symbols/boarder_1/symbol_block_A"
const TERRACOTTA_WHITE_MODEL_DIRECTORY = "minecraft:block/cloth_whale/large_symbols/symbol_block_A"
const BLOCKSTATE_FILES_SAVE_PATH = "output/blockstate/"

func generateBlockStateJsonFiles():
	var empty_template = BLOCKSTATE_TEMPLATE.duplicate(true)
	empty_template["variants"]["facing=east"].clear()
	empty_template["variants"]["facing=north"].clear()
	empty_template["variants"]["facing=south"].clear()
	empty_template["variants"]["facing=west"].clear()
	writeToFile(JSON.stringify(empty_template, "\t"),str(BLOCKSTATE_FILES_SAVE_PATH,"black_glazed_terracotta.json"))
	writeToFile(JSON.stringify(empty_template, "\t"),str(BLOCKSTATE_FILES_SAVE_PATH,"brown_glazed_terracotta.json"))
	writeToFile(JSON.stringify(empty_template, "\t"),str(BLOCKSTATE_FILES_SAVE_PATH,"cyan_glazed_terracotta.json"))
	writeToFile(JSON.stringify(empty_template, "\t"),str(BLOCKSTATE_FILES_SAVE_PATH,"white_glazed_terracotta.json"))

func addModelToBlockState(index:int, blockStateFileName: String):
	var new_model_dir = TERRACOTTA_BLACK_MODEL_DIRECTORY.replace("symbol_block_A",str("symbol_block_",index))
	addModelToBlockStateJsonFile(new_model_dir,str(BLOCKSTATE_FILES_SAVE_PATH,blockStateFileName,".json"))

func addModelToBlockStateJsonFile(modelDirectory:String,blockStateFileDirectory: String):
	var facing_east = BLOCKSTATE_TEMPLATE["variants"]["facing=east"][0].duplicate()
	var facing_north = BLOCKSTATE_TEMPLATE["variants"]["facing=north"][0].duplicate()
	var facing_south = BLOCKSTATE_TEMPLATE["variants"]["facing=south"][0].duplicate()
	var facing_west = BLOCKSTATE_TEMPLATE["variants"]["facing=west"][0].duplicate()
	
	var contents = JSON.parse_string(readFromFile(blockStateFileDirectory))
	facing_east["model"] = modelDirectory
	facing_north["model"] = modelDirectory
	facing_south["model"] = modelDirectory
	facing_west["model"] = modelDirectory
	contents["variants"]["facing=east"].append(facing_east)
	contents["variants"]["facing=north"].append(facing_north)
	contents["variants"]["facing=south"].append(facing_south)
	contents["variants"]["facing=west"].append(facing_west)
	writeToFile(JSON.stringify(contents, "\t"),blockStateFileDirectory)

func generateLargeSymbolJsonFile(index:int):
	var offset_index = index * 4
	generateModelFile("subsymbol_A",str("subsymbol_",index),str(LARGE_SYMBOLS_JSON_IN_PATH,"symbol_block_template.json"),str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json"))
	var contents = JSON.parse_string(readFromFile(str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json")))
	contents["elements"][0]["faces"]["north"]["rotation"] = 0
	contents["elements"][0]["faces"]["south"]["rotation"] = 0
	writeToFile(JSON.stringify(contents, "\t"),str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json"))
	contents = null
	
	addModelToBlockStateJsonFile(TERRACOTTA_WHITE_MODEL_DIRECTORY.replace("symbol_block_A",str("symbol_block_",offset_index)),str(BLOCKSTATE_FILES_SAVE_PATH,"white_glazed_terracotta.json"))
	
	offset_index += 1
	generateModelFile("subsymbol_A",str("subsymbol_",index),str(LARGE_SYMBOLS_JSON_IN_PATH,"symbol_block_template.json"),str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json"))
	contents = JSON.parse_string(readFromFile(str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json")))
	contents["elements"][0]["faces"]["north"]["rotation"] = 90
	contents["elements"][0]["faces"]["south"]["rotation"] = 90
	writeToFile(JSON.stringify(contents, "\t"),str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json"))
	contents = null
	
	addModelToBlockStateJsonFile(TERRACOTTA_WHITE_MODEL_DIRECTORY.replace("symbol_block_A",str("symbol_block_",offset_index)),str(BLOCKSTATE_FILES_SAVE_PATH,"white_glazed_terracotta.json"))
	
	offset_index += 1
	generateModelFile("subsymbol_A",str("subsymbol_",index),str(LARGE_SYMBOLS_JSON_IN_PATH,"symbol_block_template.json"),str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json"))
	contents = JSON.parse_string(readFromFile(str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json")))
	contents["elements"][0]["faces"]["north"]["rotation"] = 180
	contents["elements"][0]["faces"]["south"]["rotation"] = 180
	writeToFile(JSON.stringify(contents, "\t"),str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json"))
	contents = null
	
	addModelToBlockStateJsonFile(TERRACOTTA_WHITE_MODEL_DIRECTORY.replace("symbol_block_A",str("symbol_block_",offset_index)),str(BLOCKSTATE_FILES_SAVE_PATH,"white_glazed_terracotta.json"))
	
	offset_index += 1
	generateModelFile("subsymbol_A",str("subsymbol_",index),str(LARGE_SYMBOLS_JSON_IN_PATH,"symbol_block_template.json"),str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json"))
	contents = JSON.parse_string(readFromFile(str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json")))
	contents["elements"][0]["faces"]["north"]["rotation"] = 270
	contents["elements"][0]["faces"]["south"]["rotation"] = 270
	writeToFile(JSON.stringify(contents, "\t"),str(LARGE_SYMBOLS_JSON_OUT_PATH,"symbol_block_",offset_index,".json"))
	contents = null
	
	addModelToBlockStateJsonFile(TERRACOTTA_WHITE_MODEL_DIRECTORY.replace("symbol_block_A",str("symbol_block_",offset_index)),str(BLOCKSTATE_FILES_SAVE_PATH,"white_glazed_terracotta.json"))

func generateBigSymbolJsonFile(index:int):
	generateModelFile("symbol_0",str("symbol_",index),str(BIG_SYMBOLS_JSON_IN_PATH,"symbol_block_template.json"),str(BIG_SYMBOLS_JSON_OUT_PATH,"symbol_block_",index,".json"))
	var new_model_dir = TERRACOTTA_BLACK_MODEL_DIRECTORY.replace("symbol_block_A",str("symbol_block_",index))
	var save_path = str(BLOCKSTATE_FILES_SAVE_PATH,"black_glazed_terracotta.json")
	addModelToBlockStateJsonFile(new_model_dir,save_path)

func generateSmallSymbolJsonFile(index:int,totalPatterns:int):
	
	var random_index = randi_range(0,totalPatterns)
	generateModelFile("symbol_A",str("symbol_",index),str(SMALL_SYMBOLS_JSON_IN_PATH,"boarder_1/","symbol_block_template.json"),str(SMALL_SYMBOLS_JSON_OUT_PATH,"boarder_1/","symbol_block_",index,".json"))
	generateModelFile("symbol_B",str("symbol_",random_index),str(SMALL_SYMBOLS_JSON_OUT_PATH,"boarder_1/","symbol_block_",index,".json"),str(SMALL_SYMBOLS_JSON_OUT_PATH,"boarder_1/","symbol_block_",index,".json"))
	
	addModelToBlockStateJsonFile(TERRACOTTA_CYAN_MODEL_DIRECTORY.replace("symbol_block_A",str("symbol_block_",index)),str(BLOCKSTATE_FILES_SAVE_PATH,"cyan_glazed_terracotta.json"))
	
	generateModelFile("symbol_A",str("symbol_",index),str(SMALL_SYMBOLS_JSON_IN_PATH,"boarder_2/","symbol_block_template.json"),str(SMALL_SYMBOLS_JSON_OUT_PATH,"boarder_2/","symbol_block_",index,".json"))
	generateModelFile("symbol_B",str("symbol_",random_index),str(SMALL_SYMBOLS_JSON_OUT_PATH,"boarder_2/","symbol_block_",index,".json"),str(SMALL_SYMBOLS_JSON_OUT_PATH,"boarder_2/","symbol_block_",index,".json"))
	
	addModelToBlockStateJsonFile(TERRACOTTA_BROWN_MODEL_DIRECTORY.replace("symbol_block_A",str("symbol_block_",index)),str(BLOCKSTATE_FILES_SAVE_PATH,"brown_glazed_terracotta.json"))

func generateModelFile(replace_string:String,replacement_string:String,template_path:String,save_path:String):
	var template_file = FileAccess.open(template_path,FileAccess.READ)
	var contents : String = template_file.get_as_text()
	contents = contents.replace(replace_string,replacement_string)
	var out = FileAccess.open(save_path,FileAccess.WRITE)
	out.store_string(contents)
	out.close()
	template_file.close()
	out = null
	template_file = null

func readFromFile(template_path:String):
	var template_file = FileAccess.open(template_path,FileAccess.READ)
	var contents : String = template_file.get_as_text()
	template_file.close()
	template_file = null
	return contents

func writeToFile(new_content:String,save_path:String):
	var out = FileAccess.open(save_path,FileAccess.WRITE)
	out.store_string(new_content)
	out.close()
	out = null
