
extends Node2D

@onready var animacion_izq = $animaciones/frent_izq
@onready var animacion_der = $animaciones/frent_der
@onready var boton_abrir_camaras = $CanvasLayer/Button

@onready var stair: AnimatedSprite2D = $animaciones/stair
@onready var izq = $"../izq"

func _ready() -> void:
	mostrar_estatica()


func mostrar_estatica() -> void:

	var aula = get_parent()

	show()

	animacion_izq.hide()
	animacion_der.hide()

	# Comprobar si no hay energía
	if aula.sin_energia:

		$animaciones/estatica.stop()
		$animaciones/estatica.hide()

		boton_abrir_camaras.disabled = true
		boton_abrir_camaras.hide()

		return

	# Si hay energía, mostrar normalmente
	boton_abrir_camaras.disabled = false
	boton_abrir_camaras.show()

	$animaciones/estatica.show()
	$animaciones/estatica.play("default")


func _reproducir_stair() -> void:
	stair.show()
	stair.stop()
	stair.animation = "default"
	stair.set_frame_and_progress(0, 0.0)
	stair.play("default")


# =================================
# IR A LA IZQUIERDA
# =================================

func _on_izq_mouse_entered() -> void:

	var aula = get_parent()

	if not aula.bloquear_transiciones():
		return

	$animaciones/estatica.hide()
	boton_abrir_camaras.disabled = true
	boton_abrir_camaras.hide()

	animacion_izq.show()
	animacion_izq.stop()
	animacion_izq.set_frame_and_progress(0, 0.0)
	animacion_izq.play("close" if aula.puerta else "open")

	if izq.anima_en_aula:
		_reproducir_stair()
	else:
		stair.hide()

	await animacion_izq.animation_finished

	if not is_inside_tree():
		return

	if stair.is_playing():
		await stair.animation_finished

	if not is_inside_tree():
		return

	stair.stop()
	stair.hide()
	animacion_izq.hide()

	hide()

	izq.show()
	izq.vista()

	aula.desbloquear_transiciones()


# =================================
# IR A LA DERECHA
# =================================

func _on_der_mouse_entered() -> void:

	var aula = get_parent()

	if not aula.bloquear_transiciones():
		return

	$animaciones/estatica.hide()
	boton_abrir_camaras.disabled = true
	boton_abrir_camaras.hide()

	animacion_der.show()
	animacion_der.stop()
	animacion_der.set_frame_and_progress(0, 0.0)
	animacion_der.play("frent_der")

	await animacion_der.animation_finished

	if not is_inside_tree():
		return

	animacion_der.hide()

	hide()

	aula.get_node("der").show()

	aula.desbloquear_transiciones()
