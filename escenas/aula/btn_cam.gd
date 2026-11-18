
extends Button

var open: bool = false
var sin_energia: bool = false

@onready var energia = get_node("../../../vista/sistema_energia")

@onready var monitor = get_parent().get_parent().get_child(2).get_child(0)
@onready var animacion = monitor.get_child(0)
@onready var imagen = get_parent().get_parent().get_child(2).get_child(1)
@onready var mapa = get_parent().get_parent().get_child(2).get_child(2).get_child(0)


# =================================
# INICIO
# =================================

func _ready() -> void:

	open = false
	sin_energia = false

	monitor.hide()
	imagen.hide()
	mapa.hide()


# =================================
# ABRIR / CERRAR CÁMARAS
# =================================

func _on_pressed() -> void:

	if sin_energia:
		return

	if not open:
		open = true
		controlador(true)
	else:
		open = false
		controlador(false)


# =================================
# CONTROLADOR DE CÁMARAS
# =================================

func controlador(estado: bool) -> void:

	if sin_energia:
		return

	Global.camaras_activas = estado
	energia.actualizar_consumo()

	# =================================
	# MONITOR ABIERTO
	# =================================

	if estado:

		disabled = true

		monitor.show()
		animacion.play("default")

		get_parent().get_parent().get_child(0).get_child(0).get_child(0).disabled = true
		get_parent().get_parent().get_child(0).get_child(1).get_child(0).disabled = true

		await animacion.animation_finished

		if not is_inside_tree():
			return

		if sin_energia:
			return

		$"../../sonidos/monitor".play()

		imagen.show()
		mapa.show()

		hide()

	# =================================
	# MONITOR CERRADO
	# =================================

	else:

		imagen.hide()
		mapa.hide()

		$"../../sonidos/monitor".play()

		animacion.play_backwards("default")

		await animacion.animation_finished

		if not is_inside_tree():
			return

		monitor.hide()

		get_parent().get_parent().get_child(0).get_child(0).get_child(0).disabled = false
		get_parent().get_parent().get_child(0).get_child(1).get_child(0).disabled = false

		disabled = false


# =================================
# APAGÓN POR FALTA DE ENERGÍA
# =================================

func apagado_por_energia() -> void:

	if sin_energia:
		return

	sin_energia = true

	# Desactivar cámaras
	open = false
	Global.camaras_activas = false

	# Ocultar elementos del monitor
	imagen.hide()
	mapa.hide()
	monitor.hide()

	# Deshabilitar botón
	disabled = true
	hide()

	# Actualizar consumo
	energia.actualizar_consumo()

	print("Cámaras desactivadas por falta de energía.")
