extends Node

@export var source_image: Texture2D
@export var tile_set: TileSet


var tile_lookup = {} # tileset usado para consulta
var tile_grid = Array() # armazena qual tile está  em qual posição, a partir de suas coordenadas no atlas
var adjacency_rules = {}

func _ready():
	if not source_image or not tile_set:
		print("Erro: Imagem de origem ou TileSet não fornecidos. Arraste-os para o Inspector.")
		return

	build_tile_lookup()
	build_tile_grid_from_image()
	generate_adjacency_list()
	
	print("LISTA DE ADJACENCIA FINAL:")
	
	for tile_id in adjacency_rules.keys():
		print("Regras para o Tile ", tile_id, ":")
		print("  -> Pode ter à DIREITA: ", adjacency_rules[tile_id]["right"])
		print("  -> Pode ter ABAIXO: ", adjacency_rules[tile_id]["down"])
		print("  -> Pode ter à ESQUERDA: ", adjacency_rules[tile_id]["left"])
		print("  -> Pode ter ACIMA: ", adjacency_rules[tile_id]["up"])
		

func build_tile_lookup():
	var source_id = 0 
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	if not atlas:
		print("ERROR: tileset atlas not found")
		return

	var atlas_image: Image = atlas.texture.get_image()
	var tile_size = tile_set.tile_size 

	for x in range(atlas.get_atlas_grid_size().x):
		for y in range(atlas.get_atlas_grid_size().y):
			var atlas_coords = Vector2i(x, y)
			
			if atlas.has_tile(atlas_coords):
				var pixel_pos = atlas_coords * tile_size
				var region = Rect2i(pixel_pos, tile_size)
				var tile_image: Image = atlas_image.get_region(region)
				
				var data_hash = hash(tile_image.get_data())
				tile_lookup[data_hash] = atlas_coords
	
	print("CATCHED ", tile_lookup.size(), " SINGLE TILES")

func build_tile_grid_from_image():
	
	var input_image: Image = source_image.get_image()
	var tile_size = tile_set.tile_size
	
	var grid_width = input_image.get_width() / tile_size.x
	var grid_height = input_image.get_height() / tile_size.y
	
	tile_grid.resize(grid_height) 

	for y in range(grid_height):
		var row = Array() 
		row.resize(grid_width) 
		
		for x in range(grid_width):
			var pixel_pos = Vector2i(x, y) * tile_size
			var region = Rect2i(pixel_pos, tile_size)
			var chunk_image: Image = input_image.get_region(region)
			var chunk_hash = hash(chunk_image.get_data())
			
			if tile_lookup.has(chunk_hash):
				row[x] = tile_lookup[chunk_hash]
			else:
				row[x] = null
				print("tile unrecognized ", Vector2i(x, y))
		
		tile_grid[y] = row

func generate_adjacency_list():
	if tile_grid.is_empty():
		print("ERROR: tile_grid empty")
		return

	var grid_height = tile_grid.size()
	var grid_width = 0
	if grid_height > 0:
		grid_width = tile_grid.size()

	for y in range(grid_height):
		for x in range(grid_width):
			var current_tile_id = tile_grid[y][x]
			if current_tile_id == null:
				continue
			if not adjacency_rules.has(current_tile_id):
				adjacency_rules[current_tile_id] = {"right": Array(), "down": Array(), "left": Array(), "up": Array()}
			_check_neighbor_right(current_tile_id, x, y, grid_width)
			_check_neighbor_down(current_tile_id, x, y, grid_height)
			_check_neighbor_left(current_tile_id, x, y)
			_check_neighbor_up(current_tile_id, x, y)

func _check_neighbor_right(current_tile_id, x, y, grid_width):
	var neighbor_x = x + 1
	if neighbor_x < grid_width: 
		var neighbor_id = tile_grid[y][neighbor_x]
		if neighbor_id!= null:
			if not neighbor_id in adjacency_rules[current_tile_id]["right"]:
				adjacency_rules[current_tile_id]["right"].append(neighbor_id)


func _check_neighbor_down(current_tile_id, x, y, grid_height):
	var neighbor_y = y + 1
	if neighbor_y < grid_height: 
		var neighbor_id = tile_grid[neighbor_y][x]
		if neighbor_id!= null:
			if not neighbor_id in adjacency_rules[current_tile_id]["down"]:
				adjacency_rules[current_tile_id]["down"].append(neighbor_id)


func _check_neighbor_left(current_tile_id, x, y):
	var neighbor_x = x - 1
	if neighbor_x >= 0: 
		var neighbor_id = tile_grid[y][neighbor_x]
		if neighbor_id!= null:
			if not neighbor_id in adjacency_rules[current_tile_id]["left"]:
				adjacency_rules[current_tile_id]["left"].append(neighbor_id)


func _check_neighbor_up(current_tile_id, x, y):
	var neighbor_y = y - 1
	if neighbor_y >= 0: 
		var neighbor_id = tile_grid[neighbor_y][x]
		if neighbor_id != null:
			if not neighbor_id in adjacency_rules[current_tile_id]["up"]:
				adjacency_rules[current_tile_id]["up"].append(neighbor_id)
