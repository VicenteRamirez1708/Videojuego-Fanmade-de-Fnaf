
extends Node2D

@onready var timer: Timer = $hora
@onready var reloj: Label = $digito_hora
@onready var noche: Label = $digito_noche


func _ready() -> void:
	await get_tree().process_frame

	actualizar_reloj()

	if not timer.timeout.is_connected(_on_hora_timeout):
		timer.timeout.connect(_on_hora_timeout)

	timer.start()


func actualizar_reloj() -> void:
	reloj.text = str(Global.hora_actual)
	noche.text = str(Global.noche_actual)


func _on_hora_timeout() -> void:
	if not Global.noche_en_curso:
		timer.stop()
		return

	Global.avanzar_hora()
	actualizar_reloj()

	if not Global.noche_en_curso:
		timer.stop()
