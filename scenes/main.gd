extends Node2D

@onready var wfc_generator = $WFC2DGenerator
@onready var example_map = $example
@onready var target_map = $target

func _ready():
	print("Iniciando a geração do mapa WFC...")
	wfc_generator.positive_sample = example_map.get_path()
	wfc_generator.target = target_map.get_path()
	
	if not wfc_generator.rect.has_area():
		print("Aviso: O Rect não foi configurado no Inspector. Usando o tamanho padrão 50x50.")
		wfc_generator.rect = Rect2i(0, 0, 50, 50)
		
	wfc_generator.start()
	await wfc_generator.done
	
	print("Geração do mapa concluída!")
	resize_window_to_map()

func resize_window_to_map():
	var map_size_in_tiles = wfc_generator.rect.size 
	if target_map.tile_set:
		var tile_size_in_pixels = target_map.tile_set.tile_size
		var new_window_size = map_size_in_tiles * tile_size_in_pixels
		get_window().size = new_window_size
		print("Janela redimensionada para: ", new_window_size)
	else:
		print("Erro: O TileMap 'target' não tem um TileSet atribuído. Não foi possível redimensionar a janela.")
