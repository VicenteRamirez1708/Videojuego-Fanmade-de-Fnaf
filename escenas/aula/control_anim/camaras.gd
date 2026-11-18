extends Node2D

@onready var imagen: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio = $"../AudioStreamPlayer2D"

@export var velocidad: float = 40.0
@export var borde_izq: float = -150.0
@export var borde_der: float = 170.0
@export var espera_borde: float = 1.5

var posicion_inicial: Vector2
var direccion: float = 1.0
var esperando: bool = false

func _ready() -> void:
	posicion_inicial = imagen.position

func _process(delta: float) -> void:
	if esperando:
		return

	imagen.position.x += direccion * velocidad * delta

	if imagen.position.x >= posicion_inicial.x + borde_der:
		imagen.position.x = posicion_inicial.x + borde_der
		await pausar_y_girar(-1.0)

	elif imagen.position.x <= posicion_inicial.x + borde_izq:
		imagen.position.x = posicion_inicial.x + borde_izq
		await pausar_y_girar(1.0)


func pausar_y_girar(nueva_direccion: float) -> void:
	esperando = true
	await get_tree().create_timer(espera_borde).timeout
	direccion = nueva_direccion
	esperando = false
	#audio.play()
