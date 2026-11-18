
extends Node

@onready var armario = get_node("../../../../../armario")
@onready var izq = get_node("../../../../../izq")
@onready var aula = $"../../../../../"
@onready var puerta_animaciones: AnimatedSprite2D = $"../../../../../izq/animaciones/izq"
@onready var energia = $"../../../../../vista/sistema_energia"
@onready var timer: Timer = $Timer
@onready var transicion = $"../../../../../TransicionNegro"

var posicion: String = "centroA"
var posicion_anterior: String = ""

var en_puerta: bool = false
var esperando_en_puerta: bool = false

var ataque_activo: bool = false
var jumpscare_activado: bool = false

var tiempo_movimiento: float = 0.0
var inicio_ataque: float = 0.0

var stair2_activado: bool = false


func _ready() -> void:
	add_to_group("ia_stair")
	tiempo_movimiento = timer.wait_time
	ActualizarAnimacion()


# --------------------------------
# MOVIMIENTO
# --------------------------------

func moverse() -> void:

	posicion_anterior = posicion

	match posicion:
		"centroA":
			posicion = ["pasilloA", "escaleras", "escaleras"].pick_random()

		"pasilloA":
			posicion = ["centroA", "escaleras"].pick_random()

		"escaleras":
			posicion = ["centroA", "centroB", "centroB", "centroB"].pick_random()

		"centroB":
			posicion = ["escaleras", "pasilloB", "pasilloB", "pasilloB"].pick_random()

		"pasilloB":
			posicion = ["centroB", "enPuerta", "enPuerta"].pick_random()

	if posicion == "enPuerta":
		ActualizarAnimacion()
		llegar_a_puerta()
	else:
		ActualizarAnimacion()


# --------------------------------
# ACTUALIZAR CÁMARAS
# --------------------------------

func ActualizarAnimacion() -> void:

	var controlador = get_parent()

	if controlador.has_method("actualizar_todas_las_camaras"):
		controlador.actualizar_todas_las_camaras()


# --------------------------------
# DIFICULTAD
# --------------------------------

func _on_timer_timeout() -> void:

	if en_puerta or ataque_activo:
		return

	var dificultad_actual: int = Global.dificultad_animatronicos["stair"]

	if dificultad_actual >= randi_range(1, 20):
		moverse()


# --------------------------------
# ESPERA CON EL TIMER
# --------------------------------

func _esperar(segundos: float) -> void:
	timer.stop()
	timer.wait_time = segundos
	timer.start()
	await timer.timeout


# --------------------------------
# LLEGADA A LA PUERTA
# --------------------------------

func llegar_a_puerta() -> void:

	if ataque_activo:
		return

	en_puerta = true
	esperando_en_puerta = true
	ataque_activo = true
	jumpscare_activado = false
	stair2_activado = false

	timer.stop()

	inicio_ataque = Time.get_ticks_msec() / 1000.0

	# Registrar entrada al armario
	if aula.en_armario:
		armario.tiempo_entrada = inicio_ataque
	else:
		armario.tiempo_entrada = -1.0

	# Bloquear controles
	if is_instance_valid(izq):
		izq.bloquear_controles(true)

	# Abrir puerta si estaba cerrada
	if aula.puerta:
		aula.puerta = false
		Global.puerta_cerrada = false
		print("stair abrio la puerta")
		energia.actualizar_consumo()

	# Comprobar perspectiva antes de cambiarla
	var estaba_mirando_izq = izq.is_visible_in_tree()

	# =================================
	# SI ESTÁ DENTRO DEL ARMARIO
	# =================================

	if aula.en_armario:

		# No mostrar Stair en el aula
		izq.anima_en_aula = false

		# Mostrar Stair1 dentro del armario
		armario.reproducir_stair("stair1")

	# =================================
	# SI ESTÁ MIRANDO A LA IZQUIERDA
	# =================================

	elif estaba_mirando_izq:

		izq.anima_en_aula = false
		izq.mostrar_stair_estatico()

		await transicion.oscurecer()

		if jumpscare_activado or not ataque_activo:
			await transicion.aclarar()
			return

		# Mostrar Stair en la puerta
		izq.anima_en_aula = true
		izq.mostrar_stair_estatico()

		await transicion.aclarar()

	# =================================
	# SI ESTÁ EN OTRA PERSPECTIVA
	# =================================

	else:

		izq.anima_en_aula = true

	# Mostrar vista izquierda
	if not aula.en_armario and is_instance_valid(izq):
		izq.vista()

	# =================================
	# 0 A 3 SEGUNDOS
	# =================================

	await _esperar(3.0)

	if jumpscare_activado or not ataque_activo:
		return

	# Ya estaba dentro del armario
	if aula.en_armario:

		var entrada: float = armario.tiempo_entrada - inicio_ataque

		if entrada < 3.0:

			await _esperar(3.0)

			if jumpscare_activado or not ataque_activo:
				return

			if not aula.en_armario:
				jumpscare()
				return

			retirarse()
			return

	# =================================
	# 3 A 6 SEGUNDOS
	# =================================

	await _esperar(3.0)

	if jumpscare_activado or not ataque_activo:
		return

	if not aula.en_armario:
		jumpscare()
		return

	activar_stair2()

	# =================================
	# 50 / 50
	# =================================

	if randf() < 0.5:
		retirarse()
		return

	if is_instance_valid(armario):
		armario.reproducir_stair("stair3")

	# =================================
	# 3 SEGUNDOS DE STAIR 3
	# =================================

	await _esperar(3.0)

	if jumpscare_activado or not ataque_activo:
		return

	if not aula.en_armario:
		jumpscare()
		return

	retirarse()

# --------------------------------
# ACTIVAR STAIR 2
# --------------------------------

func activar_stair2() -> void:

	if stair2_activado or not ataque_activo:
		return

	stair2_activado = true

	if is_instance_valid(armario):
		armario.reproducir_stair("stair2")


# --------------------------------
# DETECTAR ENTRADA AL ARMARIO
# --------------------------------

func registrar_entrada_armario() -> void:

	if not ataque_activo or jumpscare_activado:
		return

	var tiempo_entrada: float = armario.tiempo_entrada - inicio_ataque

	print("Stair: jugador entró al armario.")
	print("Tiempo transcurrido: ", tiempo_entrada)

	# Entró antes de los 3 segundos: mostrar Stair 1
	if tiempo_entrada >= 0.0 and tiempo_entrada < 3.0:

		print("Mostrando STAIR 1 dentro del armario.")
		armario.reproducir_stair("stair1")

	# Entró entre los 3 y 6 segundos: mostrar Stair 2
	elif tiempo_entrada >= 3.0 and tiempo_entrada < 6.0:

		print("Mostrando STAIR 2 dentro del armario.")
		activar_stair2()


# --------------------------------
# DETECTAR SALIDA DEL ARMARIO
# --------------------------------

func registrar_salida_armario() -> void:

	if ataque_activo and not jumpscare_activado:
		print("¡Saliste del armario durante el ataque!")
		jumpscare()


# --------------------------------
# RETIRADA
# --------------------------------

func retirarse() -> void:

	if jumpscare_activado:
		return

	ataque_activo = false
	en_puerta = false
	esperando_en_puerta = false

	posicion = "centroB"

	timer.stop()

	if is_instance_valid(izq):
		izq.anima_en_aula = false
		izq.vista()
		izq.bloquear_controles(false)

	if is_instance_valid(armario):

		if armario.animacion_armario.animation == "stair3":
			armario.reproducir_stair_reversa()
			await armario.animacion_armario.animation_finished

		armario.anima_en_aula = false
		armario.actualizar_animacion_armario()

	if is_instance_valid(izq):
		izq.vista()

	ActualizarAnimacion()

	timer.wait_time = tiempo_movimiento
	timer.start()


# --------------------------------
# JUMPSCARE
# --------------------------------


func jumpscare() -> void:

	if jumpscare_activado:
		return

	jumpscare_activado = true
	ataque_activo = false
	en_puerta = false
	esperando_en_puerta = false

	# =================================
	# DETENER LA NOCHE
	# =================================

	Global.noche_en_curso = false

	# Detener temporizador de Stair
	timer.stop()

	# Detener el temporizador de energía
	if is_instance_valid(energia):
		energia.timer.stop()

		# Ocultar batería
		energia.bateria.hide()

		# Ocultar porcentaje
		energia.digito1.hide()
		energia.digito2.hide()

		# Ocultar filtro de energía
		energia.filtro_negro.hide()

	# =================================
	# REPRODUCIR JUMPSCARE
	# =================================

	print("¡JUMPSCARE DE STAIR!")

	$jumpscare.show()
	$jumpscare.play()
	$"../IA_Whites/grito".play()
	
	await $jumpscare.animation_finished

	# =================================
	# GAME OVER
	# =================================

	get_tree().change_scene_to_file(
		"res://escenas/game_over/game_over.tscn"
	)
