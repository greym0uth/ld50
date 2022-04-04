extends Node2D

onready var start_y = position.y
var bounce_state = 0.0

func _process(delta):
  bounce_state += delta * 4
  position.y = start_y + sin(bounce_state)