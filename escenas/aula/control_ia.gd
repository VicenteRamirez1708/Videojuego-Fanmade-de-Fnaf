
extends Node

@onready var stair = $IA_Stair
@onready var whites = $IA_Whites
@onready var forkor = $CanvasLayer/IA_Forkor

var camaras = {}

func _ready() -> void:

	camaras = {
		"cubiculosA": $"../cubiculosA/AnimatedSprite2D",
		"centroA": $"../centroA/AnimatedSprite2D",
		"escaleras": $"../escaleras/AnimatedSprite2D",
		"centroB": $"../centroB/AnimatedSprite2D",
		"salon": $"../salon/AnimatedSprite2D",
		"pasilloB": $"../pasilloB/AnimatedSprite2D",
		"pasilloA": $"../pasilloA/AnimatedSprite2D"
	}

	actualizar_todas_las_camaras()


func actualizar_todas_las_camaras() -> void:

	for nombre in camaras:

		var camara: AnimatedSprite2D = camaras[nombre]

		if not is_instance_valid(camara):
			print("ERROR: Cámara inválida: ", nombre)
			continue

		var hay_stair = stair.posicion == nombre
		var hay_whites = whites.posicion == nombre
		var hay_forkor = forkor.presente and nombre == "salon"

		if hay_forkor and hay_whites:
			camara.play("forkor_whites")

		elif hay_forkor:
			camara.play("forkor")

		elif hay_stair and hay_whites:
			camara.play("stair_whites")

		elif hay_stair:
			camara.play("stair")

		elif hay_whites:
			camara.play("whites")

		else:
			camara.play("default")


func seleccionar_camara(nombre: String) -> void:

	Global.camara_actual = nombre
