
extends Node

@onready var armario = get_node("../../../../../../armario")
@onready var izq = get_node("../../../../../../izq")
@onready var aula = $"../../../../../../"
@onready var puerta_animaciones: AnimatedSprite2D = $"../../../../../../izq/animaciones/izq"
@onready var energia = $"../../../../../../vista/sistema_energia"
@onready var timer: Timer = $Timer
@onready var transicion = $"../../../../../../TransicionNegro"

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

	if is_instance_valid(armario):
		armario.desactivar_detector_stair3()

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

		izq.anima_en_aula = false

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

	# =================================
	# COMPROBAR ENTRADA AL ARMARIO
	# =================================

	if aula.en_armario:

		var entrada: float = armario.tiempo_entrada - inicio_ataque

		if entrada < 3.0:

			await _esperar(1.5)

			if jumpscare_activado or not ataque_activo:
				return

			if not aula.en_armario:
				jumpscare()
				return

			await transicion.oscurecer()

			retirarse()

			await transicion.aclarar()

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

		await transicion.oscurecer()

		retirarse()

		await transicion.aclarar()

		return

	# =================================
	# ACTIVAR STAIR 3
	# =================================

	if is_instance_valid(armario):

		armario.reproducir_stair("stair3")
		armario.activar_detector_stair3()

	# =================================
	# VIGILAR CONTACTO STAIR 3
	# =================================

	await vigilar_stair3()

	if jumpscare_activado or not ataque_activo:
		return

	# Stair se retira si las áreas se separaron

	await transicion.oscurecer()

	retirarse()

	await transicion.aclarar()


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

	# Entró antes de los 3 segundos

	if tiempo_entrada >= 0.0 and tiempo_entrada < 3.0:

		print("Mostrando STAIR 1 dentro del armario.")

		armario.reproducir_stair("stair1")

	# Entró entre los 3 y 6 segundos

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

	if is_instance_valid(armario):
		armario.desactivar_detector_stair3()

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

	timer.stop()

	# Detener energía

	if is_instance_valid(energia):

		energia.timer.stop()

		energia.bateria.hide()

		energia.digito1.hide()
		energia.digito2.hide()

		energia.filtro_negro.hide()

	# Desactivar detectores

	if is_instance_valid(armario):
		armario.desactivar_detector_stair3()

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

	if not is_inside_tree():
		return

	get_tree().change_scene_to_file(
		"res://escenas/game_over/game_over.tscn"
	)


# =================================
# MECÁNICA DE CONTACTO STAIR 3
# =================================

func vigilar_stair3() -> void:

	if not is_instance_valid(armario):
		return

	timer.stop()

	# Guardar configuración original

	var modo_original: bool = timer.one_shot

	# Activar modo de una sola ejecución

	timer.one_shot = true

	var habia_contacto: bool = false

	while ataque_activo and not jumpscare_activado:

		await get_tree().process_frame

		if not is_inside_tree():
			return

		var contacto: bool = armario.stair3_hay_contacto()

		# =================================
		# LAS ÁREAS COMIENZAN A TOCARSE
		# =================================

		if contacto and not habia_contacto:

			print("¡Stair está alcanzando al jugador!")

			timer.stop()
			timer.wait_time = 3.0
			timer.start()

		# =================================
		# LAS ÁREAS SE SEPARAN
		# =================================

		elif not contacto and habia_contacto:

			print("¡Lograste escapar de Stair!")

			timer.stop()
			timer.one_shot = modo_original

			return

		habia_contacto = contacto

		# =================================
		# TERMINÓ EL TIEMPO DE CONTACTO
		# =================================

		if habia_contacto and timer.is_stopped():

			print("¡No lograste escapar de Stair!")

			timer.one_shot = modo_original

			jumpscare()

			return

	# =================================
	# RESTAURAR CONFIGURACIÓN
	# =================================

	timer.stop()
	timer.one_shot = modo_original
