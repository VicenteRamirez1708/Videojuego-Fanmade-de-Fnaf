extends Node2D

@onready var canvas: CanvasLayer = $CanvasLayer
@onready var fondo: ColorRect = $CanvasLayer/ColorRect
@onready var animacion: AnimationPlayer = $CanvasLayer/ColorRect/AnimationPlayer

func _ready() -> void:
	canvas.hide()
	canvas.layer = 100


func oscurecer() -> void:
	canvas.show()

	animacion.play("cerrar")
	await animacion.animation_finished


func aclarar() -> void:
	animacion.play("abrir")
	await animacion.animation_finished

	canvas.hide()
