
extends Node

@onready var luces = get_node("../../../../../izq")
@onready var aula = get_node("../../../../../")
@onready var puerta_animaciones = get_node("../../../../../izq/animaciones/izq")

var en_puerta: bool = false
var esperando: bool = false

var posicion: String = "cubiculosA"
var posicion_anterior: String = ""

var tiempo_espera: float = 5.0


func _ready() -> void:
	ActualizarAnimacion()


# =================================
# MOVIMIENTO
# =================================

func moverse() -> void:

	if en_puerta:
		return

	posicion_anterior = posicion

	match posicion:

		"cubiculosA":
			posicion = ["centroA", "centroA"].pick_random()

		"centroA":
			posicion = ["cubiculosA", "escaleras", "escaleras"].pick_random()

		"escaleras":
			posicion = ["centroA", "centroB", "centroB", "centroB"].pick_random()

		"centroB":
			posicion = ["escaleras", "pasilloB", "pasilloB", "pasilloB", "salon"].pick_random()

		"salon":
			posicion = ["centroB", "escaleras", "pasilloB", "pasilloB"].pick_random()

		"pasilloB":
			posicion = ["centroB", "enPuerta", "enPuerta"].pick_random()

	print("Whites estaba en: ", posicion_anterior)
	print("Whites ahora está en: ", posicion)

	if posicion == "enPuerta":
		en_puerta = true
		esperando = true

		if is_instance_valid(luces):
			luces.anima_en_puerta = true

		ActualizarAnimacion()

		esperar_en_puerta()


	ActualizarAnimacion()


# =================================
# ESPERA EN LA PUERTA
# =================================

func esperar_en_puerta() -> void:

	print("Whites está esperando en la puerta.")

	await get_tree().create_timer(tiempo_espera).timeout

	if not Global.noche_en_curso:
		return

	if not en_puerta:
		return

	_cerca()


# =================================
# ACTUALIZAR CÁMARAS
# =================================

func ActualizarAnimacion() -> void:

	var controlador_padre = get_parent()

	if is_instance_valid(controlador_padre):
		if controlador_padre.has_method("actualizar_todas_las_camaras"):
			controlador_padre.call_deferred("actualizar_todas_las_camaras")


# =================================
# DIFICULTAD Y MOVIMIENTO
# =================================

func _on_timer_timeout() -> void:

	if not Global.noche_en_curso:
		$Timer.stop()
		return

	if en_puerta:
		return

	var dificultad_actual: int = Global.dificultad_animatronicos["whites"]

	if dificultad_actual >= randi_range(1, 20):
		moverse()


# =================================
# COMPROBAR PUERTA
# =================================

func _cerca() -> void:

	if not en_puerta:
		return

	print("Whites intenta entrar...")

	if not aula.puerta:

		print("¡La puerta está abierta!")
		jumpscare()

	else:

		print("La puerta está cerrada. Whites se retira.")

		posicion = "pasilloB"
		en_puerta = false
		esperando = false

		if is_instance_valid(luces):
			luces.anima_en_puerta = false

		ActualizarAnimacion()


# =================================
# JUMPSCARE
# =================================

func jumpscare() -> void:

	# Detener la noche
	Global.noche_en_curso = false

	# Detener el temporizador de Whites
	$Timer.stop()

	# Detener el sistema de energía
	var energia = aula.get_node_or_null("vista/sistema_energia")

	if energia:
		energia.timer.stop()

		# Ocultar batería y porcentaje
		energia.bateria.hide()
		energia.digito1.hide()
		energia.digito2.hide()

		# Ocultar filtro de energía si está activo
		energia.filtro_negro.hide()

	# Reproducir jumpscare
	$jumpscare.show()
	$jumpscare.play()
	$grito.play()

	await $jumpscare.animation_finished

	print("¡JUMPSCARE DE WHITES!")

	get_tree().change_scene_to_file(
		"res://escenas/game_over/game_over.tscn"
	)

	# Aquí puedes conectar tu animación de derrota.
