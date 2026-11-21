
extends Node

# =================================
# CONFIGURACIÓN DE LA NOCHE
# =================================

var noche_actual: int = 1
var hora_actual: int = 12
var noche_en_curso: bool = false
var camara_actual: String = ""

var dificultad: int = 0

var dificultad_animatronicos: Dictionary = {
	"stair": 0,
	"whites": 0,
	"forkor": 0
}


# =================================
# SISTEMA DE GUARDADO
# =================================

var noche_desbloqueada: int = 1
var juego_completado: bool = false
var hay_guardado: bool = false

const RUTA_GUARDADO: String = "user://progreso.json"


func _ready() -> void:
	cargar_guardado()


# =================================
# GUARDAR PROGRESO
# =================================

func guardar_progreso() -> void:

	var datos: Dictionary = {
		"noche_desbloqueada": noche_desbloqueada,
		"juego_completado": juego_completado
	}

	var archivo = FileAccess.open(
		RUTA_GUARDADO,
		FileAccess.WRITE
	)

	if archivo == null:
		push_error("No se pudo guardar la partida.")
		return

	archivo.store_string(JSON.stringify(datos))
	archivo.close()

	hay_guardado = true

	print("Progreso guardado.")
	print("Noche desbloqueada: ", noche_desbloqueada)


# =================================
# CARGAR PROGRESO
# =================================

func cargar_guardado() -> void:

	if not FileAccess.file_exists(RUTA_GUARDADO):
		hay_guardado = false
		noche_desbloqueada = 1
		juego_completado = false
		return

	var archivo = FileAccess.open(
		RUTA_GUARDADO,
		FileAccess.READ
	)

	if archivo == null:
		hay_guardado = false
		return

	var contenido: String = archivo.get_as_text()
	archivo.close()

	var datos = JSON.parse_string(contenido)

	if typeof(datos) != TYPE_DICTIONARY:
		hay_guardado = false
		return

	noche_desbloqueada = clampi(
		int(datos.get("noche_desbloqueada", 1)),
		1,
		6
	)

	juego_completado = bool(
		datos.get("juego_completado", false)
	)

	hay_guardado = true

	print("Partida cargada.")
	print("Noche desbloqueada: ", noche_desbloqueada)


# =================================
# NUEVA PARTIDA
# =================================

func nueva_partida() -> void:

	noche_actual = 1
	hora_actual = 12

	noche_desbloqueada = 1
	juego_completado = false

	noche_en_curso = false
	cheat_activado = false

	cargar_estado_inicial()

	guardar_progreso()

	print("Nueva partida iniciada.")


# =================================
# CONTINUAR PARTIDA
# =================================

func continuar_partida() -> void:

	if not hay_guardado:
		return

	noche_actual = noche_desbloqueada

	print("Continuando desde la noche: ", noche_actual)

	get_tree().change_scene_to_file(
		"res://escenas/carga noche/carga_noche.tscn"
	)


# =================================
# CHEAT
# =================================

var cheat_activado: bool = false


# =================================
# SISTEMA DE ENERGÍA
# =================================

var energia_inicial: float = 99.0
var energia_actual: float = 99.0

var consumo_niveles: Array[float] = [
	0.12, 0.18, 0.23, 0.28
]


# =================================
# ESTADOS DE LOS SISTEMAS
# =================================

var camaras_activas: bool = false
var puerta_cerrada: bool = false
var luz_encendida: bool = false
var ventilacion_en_proceso: bool = false


# =================================
# REINICIAR ESTADOS
# =================================

func cargar_estado_inicial() -> void:

	camaras_activas = false
	puerta_cerrada = false
	luz_encendida = false
	ventilacion_en_proceso = false

	camara_actual = ""

	energia_inicial = 99.0
	energia_actual = energia_inicial


# =================================
# INICIAR NOCHE
# =================================

func iniciar_noche(numero: int) -> void:

	numero = clampi(numero, 1, 6)

	noche_actual = numero
	hora_actual = 12
	noche_en_curso = true
	cheat_activado = false

	cargar_estado_inicial()

	match numero:

		1:
			dificultad = 0
			consumo_niveles = [0.20, 0.40, 0.50, 0.60]

		2:
			dificultad = 2
			consumo_niveles = [0.22, 0.42, 0.52, 0.62]

		3:
			dificultad = 4
			consumo_niveles = [0.24, 0.44, 0.54, 0.64]

		4:
			dificultad = 6
			consumo_niveles = [0.26, 0.46, 0.56, 0.66]

		5:
			dificultad = 8
			consumo_niveles = [0.28, 0.48, 0.58, 0.68]

		6:
			dificultad = 10
			consumo_niveles = [0.30, 0.50, 0.60, 0.70]

	energia_inicial = 99.0
	energia_actual = energia_inicial

	# Dificultad inicial de los animatrónicos
	dificultad_animatronicos["stair"] = 20
	dificultad_animatronicos["whites"] = dificultad
	dificultad_animatronicos["forkor"] = dificultad

	print("==============================")
	print("INICIANDO NOCHE: ", noche_actual)
	print("Dificultad inicial: ", dificultad)
	print("==============================")


# =================================
# DETECTAR CHEAT C + D + +
# =================================

func _process(_delta: float) -> void:

	if not noche_en_curso or cheat_activado:
		return

	var tecla_c: bool = Input.is_key_pressed(KEY_C)
	var tecla_d: bool = Input.is_key_pressed(KEY_D)

	var tecla_mas: bool = (
		Input.is_key_pressed(KEY_KP_ADD)
		or (
			Input.is_key_pressed(KEY_EQUAL)
			and Input.is_key_pressed(KEY_SHIFT)
		)
	)

	if tecla_c and tecla_d and tecla_mas:
		completar_noche_cheat()


# =================================
# COMPLETAR NOCHE CON CHEAT
# =================================

func completar_noche_cheat() -> void:

	if not noche_en_curso or cheat_activado:
		return

	cheat_activado = true
	noche_en_curso = false

	print("¡CHEAT ACTIVADO!")
	print("Noche completada: ", noche_actual)

	await get_tree().create_timer(0.5).timeout

	get_tree().change_scene_to_file(
		"res://escenas/noche_completada/noche_completada.tscn"
	)


# =================================
# AVANZAR HORA
# =================================

func avanzar_hora() -> void:

	if not noche_en_curso:
		return

	if hora_actual == 12:
		hora_actual = 1
	else:
		hora_actual += 1

	# Aumentar dificultad
	for animatronico in dificultad_animatronicos.keys():
		dificultad_animatronicos[animatronico] += 1

	print("==============================")
	print("Hora: ", hora_actual, " AM")

	print("Dificultad Stair: ",
		dificultad_animatronicos["stair"])

	print("Dificultad Whites: ",
		dificultad_animatronicos["whites"])

	print("Dificultad Forkor: ",
		dificultad_animatronicos["forkor"])

	print("==============================")

	if hora_actual == 6:

		await get_tree().create_timer(0.5).timeout

		if not noche_en_curso:
			return

		noche_en_curso = false

		get_tree().change_scene_to_file(
			"res://escenas/noche_completada/noche_completada.tscn"
		)


# =================================
# OBTENER CONSUMO DE ENERGÍA
# =================================

func obtener_consumo(nivel: int) -> float:

	nivel = clampi(nivel, 1, 4)

	return consumo_niveles[nivel - 1]
