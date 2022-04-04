extends Node2D

export(Array, Resource) var recipes

onready var Sprite = get_node("Panel/Sprite")

var current_recipe

func start(index: int = 0):
  var recipe = recipes[index]
  current_recipe = recipe
  Sprite.texture = recipe.texture

  $Panel.show()

  return recipe

func start_random():
  if recipes.size() == 0:
    return null

  var index = randi() % recipes.size()
  var recipe = recipes[index]
  current_recipe = recipe
  Sprite.texture = recipe.texture

  $Panel.show()

  return recipe

func complete(dish) -> int:
  $Panel.hide()
  var value = current_recipe.value
  if dish.current_recipe.name != current_recipe.name:
    value /= 2
  current_recipe = null
  return value

onready var start_y = position.y
var bounce_state = 0.0
func _process(delta):
  if current_recipe:
    bounce_state += delta * 4
    position.y = start_y + sin(bounce_state)

func delayed_start():
  var t = Timer.new()
  t.set_wait_time(3)
  t.set_one_shot(true)
  self.add_child(t)
  t.start()
  yield(t, "timeout")
  t.queue_free()
  start_random()