
extends Node2D

@onready var hora: Label = $Label
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var proceso_finalizado: bool = false


func _ready() -> void:
	hora.hide()
	_animacion()


# =================================
# ANIMACIÓN DE NOCHE COMPLETADA
# =================================

func _animacion() -> void:

	audio.play()

	while audio.playing:
		hora.show()
		await get_tree().create_timer(0.5).timeout

		hora.hide()
		await get_tree().create_timer(0.5).timeout

	hora.hide()

	# Evitar ejecutar el proceso más de una vez
	if proceso_finalizado:
		return

	proceso_finalizado = true

	# =================================
	# SI COMPLETASTE LA NOCHE 6
	# =================================

	if Global.noche_actual >= 6:

		Global.juego_completado = true
		Global.noche_desbloqueada = 6
		Global.guardar_progreso()

		get_tree().change_scene_to_file(
			"res://escenas/creditos/creditos.tscn"
		)
		return

	# =================================
	# GUARDAR PROGRESO
	# =================================

	Global.noche_desbloqueada = max(
		Global.noche_desbloqueada,
		Global.noche_actual + 1
	)

	Global.guardar_progreso()

	# =================================
	# AVANZAR A LA SIGUIENTE NOCHE
	# =================================

	Global.noche_actual += 1

	get_tree().change_scene_to_file(
		"res://escenas/carga noche/carga_noche.tscn"
	)
