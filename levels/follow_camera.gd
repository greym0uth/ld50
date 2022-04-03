extends Camera2D

onready var Main = get_node("/root/Main");
onready var player: KinematicBody2D = Main.world().get_node("Player")

func _process(_delta):
  if current:
    position.x = player.position.x
    position.y = player.position.y