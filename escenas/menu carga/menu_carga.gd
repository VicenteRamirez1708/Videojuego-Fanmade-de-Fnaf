extends Node2D

var iniciando_noche: bool = false

func _ready() -> void:
	$Pantalla_carga/AnimationPlayer.play("menu_carga")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ir_a_noche_1()


func ir_a_noche_1() -> void:
	if iniciando_noche:
		return

	iniciando_noche = true

	$Pantalla_carga/AnimationPlayer.stop()
	Global.iniciar_noche(1)


	get_tree().change_scene_to_file("res://escenas/carga noche/carga_noche.tscn")
