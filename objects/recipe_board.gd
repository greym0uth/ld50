extends StaticBody2D

signal opened
signal closed

onready var Main = get_node("/root/Main")
onready var Hotbar = Main.ui().get_node("HUD/Hotbar")

var is_open = false
var is_just_opened = false

var current_recipe = 0

func open():
  is_open = true
  is_just_opened = true
  $Recipes.get_child(current_recipe).show()
  Main.lock_player()
  Hotbar.set_active(false)
  emit_signal("opened", self)

func close():
  is_open = false
  $Recipes.get_child(current_recipe).hide()
  Main.unlock_player()
  Hotbar.set_active(true)
  emit_signal("closed", self)

func set_current_recipe(new_recipe: int):
  $Recipes.get_child(current_recipe).hide()
  if new_recipe < 0:
    current_recipe = $Recipes.get_child_count() - 1
  else:
    current_recipe = new_recipe % $Recipes.get_child_count()
  $Recipes.get_child(current_recipe).show()

  
func _process(_delta):
  if Input.is_action_just_pressed("ui_left"):
    set_current_recipe(current_recipe - 1)
  if Input.is_action_just_pressed("ui_right"):
    set_current_recipe(current_recipe + 1)
  if Input.is_action_just_pressed("ui_cancel"):
    close()
