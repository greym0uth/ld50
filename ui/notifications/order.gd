extends Node2D

export(Array, Resource) var recipes

onready var Sprite = get_node("Panel/Sprite")

var current_recipe

func start_random():
  if recipes.size() == 0:
    return null

  var index = randi() % recipes.size()
  var recipe = recipes[index]
  current_recipe = recipe
  Sprite.texture = recipe.texture

  $Panel.show()

  return recipe

func complete(_dish) -> int:
  $Panel.hide()
  current_recipe = null
  return 100 # Have recipe include cost and then give percentage of that based on score

onready var start_y = position.y
var bounce_state = 0.0
func _process(delta):
  if current_recipe:
    bounce_state += delta * 4
    position.y = start_y + sin(bounce_state)
