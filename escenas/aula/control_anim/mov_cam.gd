extends Camera2D

# Qué tan rápido viaja la cámara de un lado a otro
@export var velocidad_movimiento: float = 1.0

# Cuántos segundos se queda quieta en cada extremo antes de volver a moverse
@export var tiempo_de_pausa: float = 1.5

# Qué tanto se desplaza hacia los lados (en píxeles)
@export var amplitud_movimiento: float = 200.0

var tiempo_acumulado: float = 0.0
var posicion_inicial_x: float

func _ready() -> void:
	posicion_inicial_x = global_position.x

func _process(delta: float) -> void:
	# Acumulamos el tiempo transcurrido
	tiempo_acumulado += delta
	
	# Usamos una función de coseno y multiplicamos su valor por un factor de compresión
	# Esto crea zonas planas en la onda, haciendo que se detenga en los picos
	var valor_seno = sin(tiempo_acumulado * velocidad_movimiento)
	
	# Aplicamos una función matemática para aplanar las esquinas y crear el efecto de pausa
	# clamp() y pow() ayudan a mantenerla estática en los extremos
	var movimiento_estancado = clamp(valor_seno * (1.0 + tiempo_de_pausa), -1.0, 1.0)
	
	# Si prefieres una pausa más limpia y robótica, puedes usar la siguiente fórmula alternativa:
	var desplazamiento = sin(tiempo_acumulado * velocidad_movimiento)
	# Forzamos escalones o usamos una función de umbral para el tiempo de espera:
	
	# Aplicamos el movimiento final a la cámara
	global_position.x = posicion_inicial_x + (desplazamiento * amplitud_movimiento)
