extends Node2D

export(int) var cash = 500

onready var Cash = get_node("UI/HUD/Cash")

var player_locked = false

func ui():
  return $UI

func world():
  return $World

func bgm():
  return $BGM

func order():
  return world().get_node("Order")

func get_cash():
  return cash

func subtract_cash(amt: int):
  return set_cash(cash - amt)

func add_cash(amt: int):
  return set_cash(cash + amt)

func set_cash(amt: int):
  cash = amt
  update_cash()
  return cash

func update_cash():
  Cash.text = String(cash) + " $"

func lock_player():
  player_locked = true

func unlock_player():
  player_locked = false

func is_player_locked():
  return player_locked

func _ready():
  update_cash()
  bgm().playing = true

func _process(_delta):
  if Input.is_action_just_pressed("pause") and not player_locked:
    ui().get_node("Menu/Pause").pause()


func toggle_music():
  bgm().playing = not bgm().playing
