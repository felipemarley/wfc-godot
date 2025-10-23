extends Node2D

@onready var wfc_generator = $WFC2DGenerator

func _ready():
	print("Iniciando a geração com regras de Terrains...")
	wfc_generator.start()
	await wfc_generator.done
	print("Geração concluída!")
