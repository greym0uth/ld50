extends RigidBody2D

signal recipe_complete

const Ingredient = preload("res://ingredients/ingredient.gd")
const Recipe = preload("res://resources/recipe.gd")

export(String) var item_name = "Basic Container"
enum Mix {
  None = 0,
  Mixed = 1
}
export(float, 0, 100, 1) var mix_percent 
export(float, 0, 3, 0.1) var mix_modifier

export(int) var mixed_at = 50

export(int) var max_contents = 5

export(bool) var can_cook = false

export(Array, Resource) var recipes = []
var current_recipe: Recipe

func do_cook(value: float):
  if can_cook:
    for item in $Contents.get_children():
      (item as Ingredient).do_cook(value)
    update_recipe()

func do_chop(value: float):
  mix_percent += value * 0.5
  update_recipe()

func get_mix():
  if mix_percent < mixed_at:
    return Mix.None
  else:
    return Mix.Mixed

func try_add_item(item: Ingredient):
  var contents_count = $Contents.get_child_count()
  if contents_count >= max_contents:
    return null
  
  item.sleeping = true
  item.get_node("CollisionShape2D").disabled = true
  $Contents.add_child(item)
  item.get_node("Sprite").scale = Vector2(0.25, 0.25)
  item.position = Vector2(contents_count, 0)
  $Contents.position.x -= 0.5

  update_recipe()
  return item

func can_transfer_items(contents: Node2D) -> bool:
  var available = max_contents - $Contents.get_child_count()
  return contents.get_child_count() <= available

func try_transfer_contents(container):
  var new_contents = container.get_node("Contents")
  if not can_transfer_items(new_contents):
    return null

  for item in new_contents.get_children():
    new_contents.remove_child(item)
    $Contents.add_child(item)
  
  update_recipe()
  return container

func is_busy():
  return $Contents.get_child_count() >= max_contents

func update_recipe():
  print("Checking recipe:")
  for recipe in recipes:
    print(recipe.name, recipe)
    if recipe.matches($Contents.get_children()):
      print(recipe.name + " was created!")
      current_recipe = recipe
      $Sprite.texture = recipe.texture
      $Sprite.region_enabled = false
      $Contents.hide()
      emit_signal("recipe_complete", self)
      return