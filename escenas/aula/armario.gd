extends Node2D

var izq: bool = false
var der: bool = false

@onready var aula = get_parent()

# Cámara
@onready var camara = $camara
@onready var camara_2d: Camera2D = $camara/Camera2D

# Animaciones
@onready var salir = $animaciones/salir
@onready var animacion_armario = $animaciones/armario

# Detectores de movimiento
@onready var detector_izq: Area2D = $CanvasLayer/detectores/izq
@onready var detector_der: Area2D = $CanvasLayer/detectores/der

@onready var colision_izq: CollisionShape2D = $CanvasLayer/detectores/izq/CollisionShape2D
@onready var colision_der: CollisionShape2D = $CanvasLayer/detectores/der/CollisionShape2D

# Detector de salida
@onready var detector_salida: Area2D = $boton/Area2D
@onready var colision_salida: CollisionShape2D = $boton/Area2D/CollisionShape2D

# Interfaz
@onready var interfaz_armario = $boton

# Variables
var posicion_inicial_camara: Vector2

var anima_en_aula: bool = false
var stair_estado_anterior: bool = false
var saliendo: bool = false
var animacion_stair_actual: String = "default"

# Registro de entrada
var tiempo_entrada: float = -1.0


func _ready() -> void:

	posicion_inicial_camara = camara.position

	salir.hide()
	interfaz_armario.hide()

	ocultar_armario()


func _process(delta: float) -> void:

	if not is_visible_in_tree():
		return

	if saliendo:
		return

	var mouse = get_viewport().get_mouse_position()

	izq = comprobar_mouse(detector_izq, mouse)
	der = comprobar_mouse(detector_der, mouse)

	mov_cam(izq, der, delta)

	if comprobar_mouse(detector_salida, mouse):
		salir_armario()
		return

	if stair_estado_anterior != anima_en_aula:
		stair_estado_anterior = anima_en_aula
		actualizar_animacion_armario()


func comprobar_mouse(area: Area2D, mouse: Vector2) -> bool:

	var colision: CollisionShape2D = area.get_node("CollisionShape2D")

	if colision.disabled:
		return false

	var rectangulo := colision.shape as RectangleShape2D

	if rectangulo == null:
		return false

	var posicion_local = colision.to_local(
		area.get_canvas_transform().affine_inverse() * mouse
	)

	var rect = Rect2(
		-rectangulo.size / 2.0,
		rectangulo.size
	)

	return rect.has_point(posicion_local)


func mov_cam(p_izq: bool, p_der: bool, delta: float) -> void:

	if p_izq:
		camara.position.x = move_toward(
			camara.position.x,
			posicion_inicial_camara.x - 350.0,
			500.0 * delta
		)

	elif p_der:
		camara.position.x = move_toward(
			camara.position.x,
			posicion_inicial_camara.x + 400.0,
			500.0 * delta
		)


# =====================================
# SALIR DEL ARMARIO
# =====================================

func salir_armario() -> void:

	if saliendo or not is_visible_in_tree():
		return

	# Comprobar si Stair está atacando
	if aula.en_armario:

		var stair = get_tree().get_first_node_in_group("ia_stair")

		if stair != null:
			stair.registrar_salida_armario()

	saliendo = true

	izq = false
	der = false

	colision_izq.set_deferred("disabled", true)
	colision_der.set_deferred("disabled", true)
	colision_salida.set_deferred("disabled", true)

	interfaz_armario.hide()

	camara.position = posicion_inicial_camara
	camara_2d.reset_smoothing()

	salir.show()
	salir.stop()
	salir.set_frame_and_progress(0, 0.0)
	salir.play("default")

	await salir.animation_finished

	salir.hide()

	ocultar_armario()

	aula.get_node("frent").mostrar_estatica()

	saliendo = false


# =====================================
# MOSTRAR ARMARIO
# =====================================

func mostrar_armario() -> void:

	show()

	izq = false
	der = false
	saliendo = false

	tiempo_entrada = Time.get_ticks_msec() / 1000.0

	camara.position = posicion_inicial_camara

	camara_2d.enabled = true
	camara_2d.make_current()
	camara_2d.reset_smoothing()

	interfaz_armario.show()

	colision_izq.set_deferred("disabled", false)
	colision_der.set_deferred("disabled", false)
	colision_salida.set_deferred("disabled", false)

	stair_estado_anterior = anima_en_aula
	actualizar_animacion_armario()

	aula.set("en_armario", true)

	var stair = get_tree().get_first_node_in_group("ia_stair")

	if stair != null:
		stair.registrar_entrada_armario()
	else:
		print("ERROR: No se encontró la IA de Stair.")


# =====================================
# OCULTAR ARMARIO
# =====================================

func ocultar_armario() -> void:

	izq = false
	der = false

	camara.position = posicion_inicial_camara

	camara_2d.enabled = false

	interfaz_armario.hide()

	aula.set("en_armario", false)

	colision_izq.set_deferred("disabled", true)
	colision_der.set_deferred("disabled", true)
	colision_salida.set_deferred("disabled", true)

	hide()


# =====================================
# ANIMACIONES DEL ARMARIO
# =====================================

func actualizar_animacion_armario() -> void:

	if anima_en_aula:

		if animacion_armario.animation != animacion_stair_actual:
			reproducir_stair(animacion_stair_actual)

	else:

		animacion_stair_actual = "default"

		if animacion_armario.animation != "default":
			animacion_armario.play("default")


# =====================================
# REPRODUCIR ANIMACIÓN ESPECÍFICA
# =====================================

func reproducir_stair(nombre: String) -> void:

	if not animacion_armario.sprite_frames.has_animation(nombre):
		print("ERROR: No existe la animación: ", nombre)
		return

	var cantidad_frames = animacion_armario.sprite_frames.get_frame_count(nombre)

	if cantidad_frames <= 0:
		print("ERROR: La animación no tiene imágenes.")
		return

	animacion_stair_actual = nombre

	animacion_armario.visible = true
	animacion_armario.stop()
	animacion_armario.animation = nombre
	animacion_armario.set_frame_and_progress(0, 0.0)

	# stair1 y stair2 son una sola imagen; stair3 sí se reproduce
	if nombre == "stair3":
		animacion_armario.play("stair3")


func reproducir_stair_reversa() -> void:

	if animacion_armario.animation == "stair3":
		animacion_armario.stop()
		animacion_armario.play_backwards("stair3")
