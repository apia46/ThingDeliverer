extends Node2D

@onready var game:Game = $".."
@onready var camera:Camera3D = $"../camera"

const SCREEN_SIZE:Vector2 = Vector2(1152, 648)

func update():
	scale = SCREEN_SIZE / game.effectiveScreenSize / 30
	position = -U.xz(camera.position) * scale * 32 + SCREEN_SIZE/2
	modulate.a = clamp(-scale.x * 3 + 1, 0, 1)

func setAllocatedSpaceMap(pos:Vector2i, tile:Vector2i):
	$"allocatedSpaceMap".set_cell(pos, 0, tile)
