extends Area2D

const Player = preload("res://characters/player/player.gd")

export(NodePath) var exit
export(NodePath) var camera

onready var exit_node: Position2D = get_node(exit)
onready var camera_node: Camera2D = get_node(camera)

func _on_Portal_body_entered(body: Node2D):
  if body is Player and exit_node != null:
    body.global_position = exit_node.global_position
    if camera_node != null:
      # print("Changing camera", camera_node)
      camera_node.make_current()
