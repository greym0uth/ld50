extends RigidBody2D

export(String) var item_name = "Basic Ingredient"
export(String) var ident = ""
export(float, 0, 3, 0.1) var cook_modifier = 1
export(float, 0, 100, 1) var cook_percent = 0
export(float, 0, 3, 0.1) var chop_modifier = 1
export(float, 0, 100, 1) var chop_percent = 0

enum Cook {
  None = 0,
  Cooked = 1,
  Burned = 2
}
export(int, 0, 100) var cooked_at = 50
export(int, 0, 100) var burned_at = 80

enum Chop {
  None = 0,
  Chopped = 1,
  Diced = 2,
  Minced = 3,
  Ground = 4
}
export(int, 0, 100) var chopped_at = 30
export(int, 0, 100) var diced_at = 50
export(int, 0, 100) var minced_at = 75 
export(int, 0, 100) var ground_at = 90

func get_cook():
  if cook_percent < cooked_at:
    return Cook.None
  elif cook_percent < burned_at:
    return Cook.Cooked
  else:
    return Cook.Burned

func get_chop():
  if chop_percent < chopped_at:
    return Chop.None
  elif chop_percent < diced_at:
    return Chop.Chopped
  elif chop_percent < minced_at:
    return Chop.Diced
  elif chop_percent < ground_at:
    return Chop.Minced
  else:
    return Chop.Ground

func do_cook(value: float):
  cook_percent += value * cook_modifier
  update_cook()

func do_chop(value: float):
  chop_percent += value * chop_modifier
  update_chop()

func update_chop():
  var chop = get_chop()
  $Sprite.region_rect.position.y = chop * 16

func update_cook():
  match get_cook():
    Cook.Cooked:
      $Sprite.modulate = Color("#b86f50")
    Cook.Burned:
      $Sprite.modulate = Color("#3f2832")

func _ready():
  update_chop()
  update_cook()
