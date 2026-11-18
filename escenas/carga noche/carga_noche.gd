extends Node2D

@onready var noche: Label = $digito_noche
@onready var animacion = $AnimatedSprite2D
@onready var audio = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_actualizar_noche()

func _actualizar_noche() -> void:
		noche.text = str(Global.noche_actual)
		animacion.show()
		animacion.play()
		audio.play()
		await animacion.animation_finished
		audio.stop()
		animacion.hide()
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://escenas/pantalla_carga/pantalla_carga.tscn")
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
