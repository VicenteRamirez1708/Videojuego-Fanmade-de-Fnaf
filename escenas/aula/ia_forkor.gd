extends Node

@onready var timer: Timer = $Timer
@onready var controlador = $".."

var presente: bool = false
var observando: bool = false
var jumpscare_activado: bool = false

var tiempo_observado: float = 0.0

const TIEMPO_JUMPSCARE: float = 3.0


func _ready() -> void:

	timer.timeout.connect(_on_timer_timeout)

	programar_siguiente_intento()


# =================================
# DETECTAR SI LO ESTÁS OBSERVANDO
# =================================

func _process(delta: float) -> void:

	if not Global.noche_en_curso:
		return

	if jumpscare_activado:
		return

	if not presente:
		return

	var esta_viendolo = (
		Global.camaras_activas
		and Global.camara_actual == "salon"
	)

	if esta_viendolo:

		# Detener el temporizador de retirada
		if not timer.is_stopped():
			timer.stop()

		if not observando:
			print("¡ESTÁS OBSERVANDO A FORKOR!")

		observando = true
		tiempo_observado += delta

		# Jumpscare después de 3 segundos
		if tiempo_observado >= TIEMPO_JUMPSCARE:
			jumpscare()

	else:

		if observando:
			print("Dejaste de observar a Forkor.")

			observando = false
			tiempo_observado = 0.0

		# Si no lo observas, iniciar el tiempo para retirarse
		if timer.is_stopped():
			timer.wait_time = randf_range(10.0, 20.0)
			timer.start()


# =================================
# TEMPORIZADOR PRINCIPAL
# =================================

func _on_timer_timeout() -> void:

	if not Global.noche_en_curso:
		timer.stop()
		return

	if jumpscare_activado:
		return

	# Si Forkor ya apareció, el Timer controla su retirada
	if presente:
		print("Forkor se retiró porque no lo observaste.")
		retirarse()
		return

	# Si no está presente, controla su siguiente aparición
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

	if jumpscare_activado or presente:
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

	if not presente or jumpscare_activado:
		return

	presente = false
	observando = false
	tiempo_observado = 0.0

	timer.stop()

	controlador.actualizar_todas_las_camaras()

	programar_siguiente_intento()


# =================================
# PROGRAMAR SIGUIENTE INTENTO
# =================================

func programar_siguiente_intento() -> void:

	if jumpscare_activado:
		return

	timer.wait_time = randf_range(10.0, 20.0)
	timer.start()


# =================================
# JUMPSCARE
# =================================

func jumpscare() -> void:

	if jumpscare_activado:
		return

	jumpscare_activado = true

	# Detener la IA
	timer.stop()
	presente = false
	observando = false
	tiempo_observado = 0.0

	# Detener la noche y las cámaras
	Global.noche_en_curso = false
	Global.camaras_activas = false
	Global.camara_actual = ""

	# Reproducir animación
	$jumpscare.show()
	$jumpscare.frame = 0
	$jumpscare.play()

	# Reproducir sonido
	var audio = $"grito"

	audio.stop()
	audio.play()

	print("Jumpscare de Forkor activado")

	# Esperar a que termine la animación
	await $jumpscare.animation_finished

	if not is_inside_tree():
		return

	# Cambiar a Game Over
	get_tree().change_scene_to_file(
		"res://escenas/game_over/game_over.tscn"
	)
