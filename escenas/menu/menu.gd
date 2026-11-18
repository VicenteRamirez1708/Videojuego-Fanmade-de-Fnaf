extends Node2D

@onready var boton_continuar = $continue
@onready var set_nueva = $Set
@onready var set_continuar = $Set2


func _ready() -> void:
	$estatica.play("default")
	$animacion.play("Idle")

	# Comprobar si existe una partida guardada
	boton_continuar.disabled = not Global.hay_guardado

	# Ocultar indicadores
	set_nueva.hide()
	set_continuar.hide()

	blip()


func _process(_delta: float) -> void:
	pass


# =================================
# EFECTO BLIP
# =================================

func blip() -> void:
	while true:
		$blip.show()
		$blip.play("blip")

		await $blip.animation_finished

		$blip.hide()

		await get_tree().create_timer(1.0).timeout


# =================================
# EFECTOS DE LOS BOTONES
# =================================

func _on_new_game_mouse_entered() -> void:
	$Set.show()


func _on_new_game_mouse_exited() -> void:
	$Set.hide()


func _on_continue_mouse_entered() -> void:
	if Global.hay_guardado:
		$Set2.show()


func _on_continue_mouse_exited() -> void:
	$Set2.hide()


# =================================
# CONTINUAR PARTIDA
# =================================

func _on_continue_pressed() -> void:
	if not Global.hay_guardado:
		return

	Global.continuar_partida()


# =================================
# NUEVA PARTIDA
# =================================

func _on_new_game_pressed() -> void:
	Global.nueva_partida()

	get_tree().change_scene_to_file(
		"res://escenas/menu carga/menu_carga.tscn"
	)


# =================================
# EFECTO GLITCH
# =================================

func _on_timer_timeout() -> void:
	$glitch.show()
	$animacion.hide()

	$glitch.play("movimiento")

	await $glitch.animation_finished

	$glitch.hide()
	$animacion.show()
