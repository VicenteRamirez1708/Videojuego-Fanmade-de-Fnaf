
extends Node2D

@onready var bateria: AnimatedSprite2D = $bateria
@onready var digito1: Label = $digito1
@onready var digito2: Label = $digito2
@onready var timer: Timer = $bateria/Timer
@onready var filtro_negro: ColorRect = $oscuro
@onready var boton_camaras: Button = $"../../frent/CanvasLayer/Button"
@onready var estatica = $"../../frent/animaciones/estatica"

var nivel_actual: int = -1
var apagon_activado: bool = false


func _ready() -> void:

	Global.energia_actual = Global.energia_inicial

	filtro_negro.hide()
	filtro_negro.color = Color(0, 0, 0, 0.85)

	# IMPORTANTE: permitir que el mouse atraviese el filtro
	filtro_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE

	timer.timeout.connect(consumir_energia)

	actualizar_porcentaje()
	actualizar_consumo()

	timer.start()


# =====================================
# CALCULAR CONSUMO
# =====================================

func calcular_nivel() -> int:

	var sistemas_activos := 0

	if Global.camaras_activas:
		sistemas_activos += 1

	if Global.puerta_cerrada:
		sistemas_activos += 1

	if Global.luz_encendida:
		sistemas_activos += 1

	if Global.ventilacion_en_proceso:
		sistemas_activos += 1

	return sistemas_activos + 1


# =====================================
# ACTUALIZAR BATERÍA
# =====================================

func actualizar_consumo() -> void:

	var nuevo_nivel := calcular_nivel()

	nivel_actual = nuevo_nivel

	if bateria.sprite_frames.has_animation(str(nivel_actual)):
		bateria.play(str(nivel_actual))
	else:
		push_warning("No existe la animación: " + str(nivel_actual))


# =====================================
# CONSUMIR ENERGÍA
# =====================================

func consumir_energia() -> void:

	if not Global.noche_en_curso:
		timer.stop()
		return

	if apagon_activado:
		return

	actualizar_consumo()

	var consumo: float = Global.obtener_consumo(nivel_actual)

	Global.energia_actual -= consumo * timer.wait_time
	Global.energia_actual = maxf(Global.energia_actual, 0.0)

	actualizar_porcentaje()

	if Global.energia_actual <= 0.0:
		timer.stop()
		activar_apagon()


# =====================================
# ACTIVAR APAGÓN
# =====================================

func activar_apagon() -> void:

	if apagon_activado:
		return

	apagon_activado = true

	print("¡SIN ENERGÍA!")

	var aula = get_parent().get_parent()
	aula.sin_energia = true

	# ---------------------------------
	# DESACTIVAR PUERTAS Y LUCES
	# ---------------------------------

	var izquierda = aula.get_node_or_null("izq")
	var derecha = aula.get_node_or_null("der")

	if izquierda and izquierda.has_method("apagado_por_energia"):
		izquierda.apagado_por_energia()

	if derecha and derecha.has_method("apagado_por_energia"):
		derecha.apagado_por_energia()

	# ---------------------------------
	# DESACTIVAR CÁMARAS
	# ---------------------------------

	Global.camaras_activas = false

	if is_instance_valid(boton_camaras):
		if boton_camaras.has_method("apagado_por_energia"):
			boton_camaras.apagado_por_energia()
		else:
			boton_camaras.disabled = true

	# ---------------------------------
	# ACTIVAR FILTRO NEGRO
	# ---------------------------------

	filtro_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filtro_negro.show()
	estatica.hide()
	
	print("Sistemas desactivados. Filtro negro activado.")


# =====================================
# ACTUALIZAR PORCENTAJE
# =====================================

func actualizar_porcentaje() -> void:

	var porcentaje_actual := int(Global.energia_actual)

	digito1.text = str(porcentaje_actual / 10)
	digito2.text = str(porcentaje_actual % 10)
