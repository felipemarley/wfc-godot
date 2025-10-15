extends Node2D
@onready var wfc_generator = $WFC2DGenerator

func _ready():
	print("Iniciando a geração do mapa WFC...")
	wfc_generator.start()
	await wfc_generator.done
	print("Geração do mapa concluída!")
	#await RenderingServer.frame_post_draw
	#get_viewport().get_texture().get_image().save_png("user://Screenshot.png")
