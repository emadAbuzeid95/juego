## Configuración global del juego.
## Contiene todas las constantes usadas en el proyecto.
extends Node

## === COLUMNAS ===
## Número de columnas en el juego
const COLS: int = 4
## Ancho de cada columna en píxeles
const COL_WIDTH: int = 80
## Posición X donde empiezan las columnas
const COL_START_X: int = 200
## Posición Y donde spawnean las piezas (fuera de pantalla)
const SPAWN_Y: int = -50
## Posición Y donde el jugador atrapa las piezas
const CATCH_Y: int = 620
## Tamaño del área del jugador
const PLAYER_SIZE: int = 80
## Tamaño de cada pieza
const PIECE_SIZE: int = 80

## === COMBO ===
## Cantidad de piezas que forman un combo válido
const COMBO_SIZE: int = 3

## === PROGRESS ===
## Puntuación necesaria para completar el nivel
const PROGRESS_TARGET: int = 15

## === COLORS ===
## Colores disponibles para las piezas (hex)
const COLOR_PIECE = ["#e94560", "#0f3460", "#16c79a", "#f7b731"]
## Color para slots vacíos del combo
const COLOR_EMPTY: Color = Color(0.3, 0.3, 0.3)