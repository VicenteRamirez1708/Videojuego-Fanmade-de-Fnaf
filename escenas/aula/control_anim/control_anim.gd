
extends Node2D

@onready var energia = $"../../../vista/sistema_energia"
@onready var sonido = $"../mapa/AudioStreamPlayer2D"

# --- CÁMARAS ---

@onready var camaras: Array = [
	$auditorio, $pasilloA, $centroA, $baños, $cubiculosA,
	$pasilloB, $centroB, $salon, $cubiculosB, $escaleras,
	$vent1A, $vent2A, $vent1B, $vent2B, $vent1C, $vent2C
]

var nombres_camaras: Array[String] = [
	"auditorio",
	"pasilloA",
	"centroA",
	"baños",
	"cubiculosA",
	"pasilloB",
	"centroB",
	"salon",
	"cubiculosB",
	"escaleras",
	"vent1A",
	"vent2A",
	"vent1B",
	"vent2B",
	"vent1C",
	"vent2C"
]

# --- CONTENEDORES DE LOS MAPAS ---

@onready var mapa_1 = $"../mapa/CanvasLayer/mapa_P1"
@onready var mapa_2 = $"../mapa/CanvasLayer/mapa_p2"
@onready var mapa_v = $"../mapa/CanvasLayer/mapa_v"

# --- BOTONES PARA CAMBIAR DE MAPA ---

@onready var btn_piso_1 = $"../mapa/CanvasLayer/botones/piso1/piso1"
@onready var btn_piso_2 = $"../mapa/CanvasLayer/botones/piso2/piso2"
@onready var btn_vent = $"../mapa/CanvasLayer/botones/vent/vent"

# --- BOTONES DEL MAPA 1 ---

@onready var botones_mapa_1: Array = [
	$"../mapa/CanvasLayer/mapa_P1/auditorio/auditorio",
	$"../mapa/CanvasLayer/mapa_P1/pasilloA/pasilloA",
	$"../mapa/CanvasLayer/mapa_P1/centroA/centroA",
	$"../mapa/CanvasLayer/mapa_P1/baños/baños",
	$"../mapa/CanvasLayer/mapa_P1/cubiculosA/cubiculosA"
]

# --- BOTONES DEL MAPA 2 ---

@onready var botones_mapa_2: Array = [
	$"../mapa/CanvasLayer/mapa_p2/pasilloB/pasilloB",
	$"../mapa/CanvasLayer/mapa_p2/centroB/centroB",
	$"../mapa/CanvasLayer/mapa_p2/salon/salon",
	$"../mapa/CanvasLayer/mapa_p2/cubiculosB/cubiculosB",
	$"../mapa/CanvasLayer/mapa_p2/escaleras/escaleras"
]

# --- BOTONES DEL MAPA DE VENTILACIÓN ---

@onready var botones_mapa_v: Array = [
	$"../mapa/CanvasLayer/mapa_v/vent1A/vent1A",
	$"../mapa/CanvasLayer/mapa_v/vent2A/vent2A",
	$"../mapa/CanvasLayer/mapa_v/vent1B/vent1B",
	$"../mapa/CanvasLayer/mapa_v/vent2B/vent2B",
	$"../mapa/CanvasLayer/mapa_v/vent1C/vent1C",
	$"../mapa/CanvasLayer/mapa_v/vent2C/vent2C"
]

# --- BOTONES DE CONTROL DE VENTILACIÓN ---

@onready var botones_control_vent: Array = [
	$"../mapa/CanvasLayer/mapa_v/botones/vent_close1A/vent_close1A",
	$"../mapa/CanvasLayer/mapa_v/botones/vent_close2A/vent_close2A",
	$"../mapa/CanvasLayer/mapa_v/botones/vent_close1B/vent_close1B",
	$"../mapa/CanvasLayer/mapa_v/botones/vent_close2B/vent_close2B",
	$"../mapa/CanvasLayer/mapa_v/botones/vent_close1C/vent_close1C",
	$"../mapa/CanvasLayer/mapa_v/botones/vent_close2C/vent_close2C"
]

# --- ESTADO DE LAS VENTILACIONES ---

var ventilaciones_abiertas: Array[bool] = [
	true, true, true, true, true, true
]

var ventilaciones_en_proceso: Array[bool] = [
	false, false, false, false, false, false
]

# --- MEMORIA DE CÁMARAS ---

var ultima_camara_piso_1: int = 0
var ultima_camara_piso_2: int = 5
var ultima_camara_v: int = 10

# --- BOTÓN PARA CERRAR EL MONITOR ---

@onready var boton_abrir_monitor = $"../../CanvasLayer/Button"


# =================================
# INICIALIZACIÓN
# =================================

func _ready() -> void:

	cambiar_camara(0)

	actualizar_indicadores_ventilacion()


func actualizar_indicadores_ventilacion() -> void:

	for i in range(botones_control_vent.size()):

		var boton = botones_control_vent[i]
		var fondo = boton.get_node_or_null("Sprite2D")

		if fondo:
			fondo.visible = ventilaciones_abiertas[i]


# =================================
# ACTUALIZAR ESTADO DEL MONITOR
# =================================

func actualizar_estado_monitor(estado: bool) -> void:

	Global.camaras_activas = estado
	energia.actualizar_consumo()

	if not estado:
		Global.camara_actual = ""


# =================================
# CAMBIAR DE MAPA
# =================================

func cambiar_a_mapa_1() -> void:

	mapa_1.show()
	mapa_2.hide()
	mapa_v.hide()


func cambiar_a_mapa_2() -> void:

	mapa_1.hide()
	mapa_2.show()
	mapa_v.hide()


func cambiar_a_mapa_v() -> void:

	mapa_1.hide()
	mapa_2.hide()
	mapa_v.show()


# =================================
# CAMBIAR DE CÁMARA
# =================================

func cambiar_camara(camara: int) -> void:

	if camara < 0 or camara >= camaras.size():
		return

	sonido.play()

	if camara <= 4:

		ultima_camara_piso_1 = camara
		cambiar_a_mapa_1()

	elif camara <= 9:

		ultima_camara_piso_2 = camara
		cambiar_a_mapa_2()

	else:

		ultima_camara_v = camara
		cambiar_a_mapa_v()

	# Ocultar todas las cámaras.
	for camara_actual in camaras:
		camara_actual.hide()

	# Mostrar cámara seleccionada.
	camaras[camara].show()

	# Informar al controlador de IA.
	Global.camara_actual = nombres_camaras[camara]

	# Ocultar indicadores de cámaras.
	for boton in botones_mapa_1:

		var sprite = boton.get_node_or_null("Sprite2D")

		if sprite:
			sprite.hide()

	for boton in botones_mapa_2:

		var sprite = boton.get_node_or_null("Sprite2D")

		if sprite:
			sprite.hide()

	for boton in botones_mapa_v:

		var sprite = boton.get_node_or_null("Sprite2D")

		if sprite:
			sprite.hide()

	# Ocultar indicadores de pisos.
	var sprite_p1 = btn_piso_1.get_node_or_null("Sprite2D")
	var sprite_p2 = btn_piso_2.get_node_or_null("Sprite2D")
	var sprite_v = btn_vent.get_node_or_null("Sprite2D")

	if sprite_p1:
		sprite_p1.hide()

	if sprite_p2:
		sprite_p2.hide()

	if sprite_v:
		sprite_v.hide()

	# Mostrar indicador seleccionado.
	if camara <= 4:

		if sprite_p1:
			sprite_p1.show()

		var sprite = botones_mapa_1[camara].get_node_or_null("Sprite2D")

		if sprite:
			sprite.show()

	elif camara <= 9:

		if sprite_p2:
			sprite_p2.show()

		var indice = camara - 5
		var sprite = botones_mapa_2[indice].get_node_or_null("Sprite2D")

		if sprite:
			sprite.show()

	else:

		if sprite_v:
			sprite_v.show()

		var indice = camara - 10
		var sprite = botones_mapa_v[indice].get_node_or_null("Sprite2D")

		if sprite:
			sprite.show()


# =================================
# CAMBIAR ESTADO DE UNA VENTILACIÓN
# =================================

func cambiar_ventilacion(indice: int) -> void:

	if indice < 0 or indice >= ventilaciones_abiertas.size():
		return

	# Evitar otra operación mientras se procesa una ventilación.
	for proceso in ventilaciones_en_proceso:

		if proceso:
			return

	ventilaciones_en_proceso[indice] = true

	Global.ventilacion_en_proceso = true
	energia.actualizar_consumo()

	await get_tree().create_timer(3.0).timeout

	if not is_inside_tree():
		return

	if not Global.noche_en_curso:

		ventilaciones_en_proceso[indice] = false
		Global.ventilacion_en_proceso = false
		energia.actualizar_consumo()
		return

	# Abrir todas las ventilaciones.
	for i in range(ventilaciones_abiertas.size()):
		ventilaciones_abiertas[i] = true

	# Cerrar solamente la seleccionada.
	ventilaciones_abiertas[indice] = false

	ventilaciones_en_proceso[indice] = false

	Global.ventilacion_en_proceso = false

	actualizar_indicadores_ventilacion()
	energia.actualizar_consumo()


# =================================
# SEÑALES DE LAS CÁMARAS DEL PISO 1
# =================================

func _on_auditorio_pressed() -> void:
	cambiar_camara(0)

func _on_pasillo_a_pressed() -> void:
	cambiar_camara(1)

func _on_centro_a_pressed() -> void:
	cambiar_camara(2)

func _on_baños_pressed() -> void:
	cambiar_camara(3)

func _on_cubiculos_a_pressed() -> void:
	cambiar_camara(4)


# =================================
# SEÑALES DE LAS CÁMARAS DEL PISO 2
# =================================

func _on_pasillo_b_pressed() -> void:
	cambiar_camara(5)

func _on_centro_b_pressed() -> void:
	cambiar_camara(6)

func _on_salon_pressed() -> void:
	cambiar_camara(7)

func _on_cubiculos_b_pressed() -> void:
	cambiar_camara(8)

func _on_escaleras_pressed() -> void:
	cambiar_camara(9)


# =================================
# SEÑALES DE LAS CÁMARAS DE VENTILACIÓN
# =================================

func _on_vent_1a_pressed() -> void:
	cambiar_camara(10)

func _on_vent_2a_pressed() -> void:
	cambiar_camara(11)

func _on_vent_1b_pressed() -> void:
	cambiar_camara(12)

func _on_vent_2b_pressed() -> void:
	cambiar_camara(13)

func _on_vent_1c_pressed() -> void:
	cambiar_camara(14)

func _on_vent_2c_pressed() -> void:
	cambiar_camara(15)


# =================================
# SEÑALES DE CERRAR VENTILACIONES
# =================================

func _on_vent_close_1a_pressed() -> void:
	cambiar_ventilacion(0)

func _on_vent_close_2a_pressed() -> void:
	cambiar_ventilacion(1)

func _on_vent_close_1b_pressed() -> void:
	cambiar_ventilacion(2)

func _on_vent_close_2b_pressed() -> void:
	cambiar_ventilacion(3)

func _on_vent_close_1c_pressed() -> void:
	cambiar_ventilacion(4)

func _on_vent_close_2c_pressed() -> void:
	cambiar_ventilacion(5)


# =================================
# SALIR DE LAS CÁMARAS
# =================================

func _on_salir_camaras_mouse_entered() -> void:

	if boton_abrir_monitor:

		boton_abrir_monitor.open = false
		boton_abrir_monitor.controlador(false)
		boton_abrir_monitor.show()

		actualizar_estado_monitor(false)


# =================================
# BOTONES PARA CAMBIAR DE MAPA
# =================================

func _on_piso_1_pressed() -> void:
	cambiar_camara(ultima_camara_piso_1)

func _on_piso_2_pressed() -> void:
	cambiar_camara(ultima_camara_piso_2)

func _on_vent_pressed() -> void:
	cambiar_camara(ultima_camara_v)
