extends Node2D

@onready var noche = Global.noche_actual

func _ready() -> void:
	Global.iniciar_noche(noche)
