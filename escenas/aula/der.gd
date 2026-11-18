
extends Node2D

@onready var animacion_der = $Animaciones/der_frent
@onready var armario = $Animaciones/armario
@onready var sonido_armario = $sonidos/armario
@onready var sonido_correr = $sonidos/correr


func _ready() -> void:
	animacion_der.hide()
	armario.hide()


# =================================
# REGRESAR A LA VISTA FRONTAL
# =================================

func _on_area_2d_mouse_entered() -> void:

	var aula = get_parent()

	if not aula.bloquear_transiciones():
		return

	animacion_der.show()
	animacion_der.stop()
	animacion_der.set_frame_and_progress(0, 0.0)
	animacion_der.play("der_frent")

	await animacion_der.animation_finished

	if not is_inside_tree():
		return

	animacion_der.hide()

	hide()

	var vista_frent = aula.get_node("frent")
	vista_frent.show()
	vista_frent.mostrar_estatica()

	aula.desbloquear_transiciones()


# =================================
# ENTRAR AL ARMARIO
# =================================

func _on_button_pressed() -> void:

	var aula = get_parent()

	if not aula.bloquear_transiciones():
		return

	# Reproducir animación de esconderse
	armario.show()
	armario.stop()
	armario.set_frame_and_progress(0, 0.0)
	armario.play("esconderse")

	sonido_correr.play()

	await armario.animation_finished

	if not is_inside_tree():
		return

	sonido_armario.play()
	armario.hide()

	hide()

	# Mostrar armario
	var vista_armario = aula.get_node("armario")
	vista_armario.mostrar_armario()

	aula.desbloquear_transiciones()
