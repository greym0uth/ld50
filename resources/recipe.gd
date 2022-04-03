extends Resource

const Ingredient = preload("res://ingredients/ingredient.gd")

export(String) var name
export(Texture) var texture
export(Array, Resource) var ingredients

var translated_ingredients: Dictionary

func _init(r_name = "Base", r_texture = null, r_ingredients = []):
  name = r_name
  texture = r_texture
  ingredients = r_ingredients

  translated_ingredients = translate(r_ingredients)

func translate(ingredients_arr):
  var ingredients_dict = {}
  for ingredient in ingredients_arr:
    var cook = translate_cook(ingredient[1])
    var chop = translate_chop(ingredient[2])
    ingredients_dict[ingredient[0]] = {
      cook: cook,
      chop: chop
    }
  return ingredients_dict

func translate_cook(cook: String):
  match cook:
    "cooked": return Ingredient.Cook.Cooked
    "burned": return Ingredient.Cook.Burned
    _: return Ingredient.Cook.None

func translate_chop(chop: String):
  match chop:
    "chopped": return Ingredient.Chop.Chopped
    "diced": return Ingredient.Chop.Diced
    "minced": return Ingredient.Chop.Minced
    "ground": return Ingredient.Chop.Ground
    _: return Ingredient.Chop.None

func matches(contents):
  # TODO: Actually check all the ingredients match
  if contents.size() != ingredients.size():
    return false

  for item in contents:
    # print("Checking item: " + item.ident, String(item.get_cook()) + ":" + String(item.get_chop()))
    var has_match = false
    for ingredient in ingredients:
      # print("Against: " + ingredient.name, String(ingredient.cook) + ":" + String(ingredient.chop))
      if item.ident == ingredient.name and item.get_cook() == ingredient.cook and item.get_chop() == ingredient.chop:
        has_match = true
        break
    if not has_match:
      return false

  return true
