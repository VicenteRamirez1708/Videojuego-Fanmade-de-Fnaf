
extends Node2D

var puerta: bool = false
var en_armario: bool = false
var transicionando: bool = false
var sin_energia: bool = false


# =====================================
# CONTROL DE TRANSICIONES
# =====================================

func bloquear_transiciones() -> bool:

	if transicionando:
		return false

	transicionando = true
	return true


func desbloquear_transiciones() -> void:

	transicionando = false


# =====================================
# INICIO DEL AULA
# =====================================

func _ready() -> void:

	$Ambiente.play()

	$frent.show()
	$izq.hide()
	$der.hide()

	sin_energia = false


func _process(delta: float) -> void:
	pass
