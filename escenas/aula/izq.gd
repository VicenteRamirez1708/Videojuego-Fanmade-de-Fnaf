
extends Node2D

@onready var animacion_izq_frent = $animaciones/izq_frent
@onready var animacion_puerta = $animaciones/izq
@onready var boton = $boton/boton
@onready var energia = get_node("../vista/sistema_energia")
@onready var stair: AnimatedSprite2D = $animaciones/stair
@onready var btn_luz: Button = $boton/btn_luz
@onready var btn_puerta: Button = $boton/btn_puerta

var luz: bool = false
var anima_en_puerta: bool = false
var anima_en_aula: bool = false
var controles_bloqueados: bool = false


# =================================
# INICIO
# =================================

func _ready() -> void:
	Global.luz_encendida = false
	Global.puerta_cerrada = get_parent().puerta

	vista()


# =================================
# VISTA IZQUIERDA
# =================================

func vista() -> void:

	var aula = get_parent()

	animacion_izq_frent.hide()
	animacion_puerta.show()
	boton.show()

	if aula.puerta:

		boton.play("close")
		boton.set_frame_and_progress(
			boton.sprite_frames.get_frame_count("close") - 1, 0.0
		)

		animacion_puerta.play("close")
		animacion_puerta.set_frame_and_progress(
			animacion_puerta.sprite_frames.get_frame_count("close") - 1, 0.0
		)

	else:

		boton.play("open")
		boton.set_frame_and_progress(
			boton.sprite_frames.get_frame_count("open") - 1, 0.0
		)

		animacion_puerta.play("open")
		animacion_puerta.set_frame_and_progress(
			animacion_puerta.sprite_frames.get_frame_count("open") - 1, 0.0
		)

	mostrar_stair_estatico()


# =================================
# REGRESAR A LA VISTA FRONTAL
# =================================

func _on_area_2d_mouse_entered() -> void:

	var aula = get_parent()

	if not aula.bloquear_transiciones():
		return

	boton.hide()
	animacion_puerta.hide()

	animacion_izq_frent.show()
	animacion_izq_frent.stop()
	animacion_izq_frent.set_frame_and_progress(0, 0.0)
	animacion_izq_frent.play("close" if aula.puerta else "open")

	if anima_en_aula:
		stair.show()
		stair.stop()
		stair.animation = "default"
		stair.set_frame_and_progress(0, 0.0)
		stair.play("default")
	else:
		stair.hide()

	await animacion_izq_frent.animation_finished

	if not is_inside_tree():
		return

	if stair.is_playing():
		await stair.animation_finished

	if not is_inside_tree():
		return

	stair.stop()
	stair.hide()
	animacion_izq_frent.hide()

	hide()

	var vista_frent = aula.get_node("frent")
	vista_frent.show()
	vista_frent.mostrar_estatica()

	aula.desbloquear_transiciones()


# =================================
# PUERTA
# =================================

func _on_btn_puerta_pressed() -> void:

	if controles_bloqueados:
		return

	var aula = get_parent()

	if not aula.puerta:
		aula.puerta = true
		$sonidos/puerta.play()
	else:
		aula.puerta = false

	Global.puerta_cerrada = aula.puerta
	energia.actualizar_consumo()

	if luz:
		puerta()
	else:
		vista()

	await boton.animation_finished


# =================================
# ENCENDER LUZ
# =================================

func _on_btn_luz_button_down() -> void:

	if controles_bloqueados:
		return

	luz = true
	Global.luz_encendida = true
	energia.actualizar_consumo()

	var aula = get_parent()

	$sonidos/light.play()

	if anima_en_puerta:

		if aula.puerta:
			animacion_puerta.play("close_whites")
			boton.play("both")
			print("Whites está en la puerta y la puerta está cerrada.")

		else:
			animacion_puerta.play("open_whites")
			boton.play("light")
			print("Whites está en la puerta y la puerta está abierta.")

	else:
		puerta()


# =================================
# APAGAR LUZ
# =================================

func _on_btn_luz_button_up() -> void:

	if controles_bloqueados:
		return

	luz = false
	Global.luz_encendida = false
	energia.actualizar_consumo()

	vista()


# =================================
# STAIR ESTÁTICO
# =================================

func mostrar_stair_estatico() -> void:

	if anima_en_aula:
		stair.show()
		stair.stop()
		stair.animation = "default"
		stair.set_frame_and_progress(0, 0.0)
	else:
		stair.hide()


# =================================
# ANIMACIÓN DE PUERTA CON LUZ
# =================================

func puerta() -> void:

	var aula = get_parent()

	if luz:

		if aula.puerta:
			boton.play("both")
			animacion_puerta.play("close_light")

		else:
			boton.play("light")
			animacion_puerta.play("open_light")

	else:
		vista()


# =================================
# BLOQUEAR CONTROLES
# =================================

func bloquear_controles(bloquear: bool) -> void:

	controles_bloqueados = bloquear

	btn_luz.disabled = bloquear
	btn_puerta.disabled = bloquear

	print("Controles bloqueados: ", bloquear)


# =================================
# APAGÓN POR FALTA DE ENERGÍA
# =================================

func apagado_por_energia() -> void:

	print("Izquierda: apagón activado.")

	# Bloquear únicamente los botones
	bloquear_controles(true)

	# Apagar la luz
	luz = false
	Global.luz_encendida = false

	# Restaurar la apariencia de la puerta
	vista()

	print("Luz y puerta desactivadas por falta de energía.")
