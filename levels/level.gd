extends Node2D

const Player = preload("res://characters/player/player.gd")

signal level_exited

func _on_Exit_body_entered(body:Node):
  if body is Player:
    emit_signal("level_exited")
