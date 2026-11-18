extends Camera2D

# Ya no necesitamos mover la Camera2D, movemos toda la escena visual de la cámara
var direccion: float = 1.0   
var velocidad: float = 100.0 

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
		
	# Movemos todo el nodo contenedor de la cámara en el eje X
	position.x += velocidad * direccion * delta
	
	# Si llega al límite derecho (170), cambia de rumbo
	if position.x >= 170.0:
		position.x = 170.0
		direccion = -1.0
		
	# Si llega al límite izquierdo (-150), cambia de rumbo
	elif position.x <= -150.0:
		position.x = -150.0
		direccion = 1.0
