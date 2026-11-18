
extends Node

@onready var timer: Timer = $Timer
@onready var controlador = $"../.."
@onready var canvas: CanvasLayer = get_parent()

@onready var sprite: AnimatedSprite2D = $jumpscare
@onready var grito = $"../../IA_Whites/grito"

var presente: bool = false
var jumpscare_activado: bool = false
var observando: bool = false

var tiempo_observado: float = 0.0

const TIEMPO_JUMPSCARE: float = 3.0
const CAPA_JUMPSCARE: int = 100


func _ready() -> void:

	timer.timeout.connect(_on_timer_timeout)

	sprite.hide()

	programar_siguiente_intento()


func _process(delta: float) -> void:

	if not presente or jumpscare_activado:
		return

	if not Global.noche_en_curso:
		return

	var esta_viendolo = (
		Global.camaras_activas
		and Global.camara_actual == "salon"
	)

	if esta_viendolo:

		if not observando:
			print("¡ESTÁS OBSERVANDO A FORKOR!")

		observando = true
		tiempo_observado += delta

		if tiempo_observado >= TIEMPO_JUMPSCARE:
			jumpscare()

	else:

		if observando:
			print("Dejaste de observar a Forkor.")
			retirarse()


# =================================
# INTENTO DE APARICIÓN
# =================================

func _on_timer_timeout() -> void:

	if not Global.noche_en_curso:
		timer.stop()
		return

	if presente or jumpscare_activado:
		return

	var dificultad_forkor: int = Global.dificultad_animatronicos["forkor"]

	var probabilidad: int = clampi(
		dificultad_forkor * 5,
		0,
		100
	)

	print("Probabilidad de Forkor: ", probabilidad, "%")

	if randi_range(1, 100) <= probabilidad:
		aparecer()
	else:
		print("Forkor no apareció.")
		programar_siguiente_intento()


# =================================
# APARECER
# =================================

func aparecer() -> void:

	if presente or jumpscare_activado:
		return

	presente = true
	observando = false
	tiempo_observado = 0.0

	timer.stop()

	print("¡FORKOR APARECIÓ EN EL SALÓN!")

	controlador.actualizar_todas_las_camaras()


# =================================
# RETIRARSE
# =================================

func retirarse() -> void:

	if not presente:
		return

	presente = false
	observando = false
	tiempo_observado = 0.0

	controlador.actualizar_todas_las_camaras()

	programar_siguiente_intento()


# =================================
# PROGRAMAR SIGUIENTE INTENTO
# =================================

func programar_siguiente_intento() -> void:

	timer.wait_time = randf_range(10.0, 20.0)
	timer.start()


# =================================
# JUMPSCARE
# =================================

func jumpscare() -> void:

	if jumpscare_activado:
		return

	jumpscare_activado = true
	presente = false
	observando = false

	Global.noche_en_curso = false
	Global.camaras_activas = false
	Global.camara_actual = ""

	timer.stop()

	# Actualizar cámaras.
	controlador.actualizar_todas_las_camaras()

	# Prioridad del CanvasLayer.
	canvas.layer = CAPA_JUMPSCARE
	canvas.visible = true

	# Configurar sprite.
	sprite.show()
	sprite.modulate = Color.WHITE
	sprite.z_index = 100

	# Centrar en la pantalla.
	sprite.position = get_viewport().get_visible_rect().size / 2.0

	# Reproducir audio.
	if is_instance_valid(grito):
		grito.play()
	else:
		print("ERROR: No se encontró el audio grito.")

	# Reproducir animación.
	if sprite.sprite_frames.has_animation("jumpscare"):

		sprite.sprite_frames.set_animation_loop("jumpscare", false)

		sprite.animation = "jumpscare"
		sprite.frame = 0

		print("Frames del jumpscare: ", sprite.sprite_frames.get_frame_count("jumpscare"))

		sprite.play("jumpscare")

		# Esperar hasta que finalice.
		await sprite.animation_finished

	else:

		push_error("No existe la animación jumpscare.")
		await get_tree().create_timer(2.0).timeout

	# Cambiar de escena.
	get_tree().change_scene_to_file(
		"res://escenas/game_over/game_over.tscn"
	)
