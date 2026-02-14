extends Node2D

@onready var tile_map = $TileMapLayer
@onready var player = $Player

var noise = FastNoiseLite.new()
var width = 100  # How wide the world is
var height = 100 # How tall the world is

func _ready():
	randomize() # Make sure it's different every time
	noise.seed = randi()
	noise.frequency = 0.05 # Lower = larger blobs of terrain
	
	generate_world()

func generate_world():
	var wall_cells_list = [] # We will store all wall coordinates here
	
	for x in range(-width, width):
		for y in range(-height, height):
			var noise_val = noise.get_noise_2d(x, y)
			
			if noise_val < 0.4:
				# FLOOR: You can keep using set_cell for the simple floor
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(13, 15)) # Use your floor coords
			else:
				# WALL: Don't set it yet! Just remember "This spot is a wall"
				wall_cells_list.append(Vector2i(x, y))

	# THE MAGIC LINE
	# arguments: (layer, list_of_cells, terrain_set_id, terrain_id)
	tile_map.set_cells_terrain_connect(wall_cells_list, 0, 0)