extends Control

const ItemContainer = preload("res://containers/item_container.gd")
const Ingredient = preload("res://ingredients/ingredient.gd")

var is_running = true
var step = 0

onready var Main = get_node("/root/Main")
onready var Objects = Main.world().get_node("Layers/Objects")

onready var welcome = get_node("Welcome")
onready var new_order = get_node("NewOrder")
onready var grab_ingredients = get_node("GrabIngredients")
onready var drop_bowl_here = Main.world().get_node("Tutorial/DropBowlHere")
onready var drop_plate_here = Main.world().get_node("Tutorial/DropPlateHere")
onready var chop_lettuce = get_node("ChopLettuce")
onready var grab_lettuce_now = get_node("GrabLettuceNow")
onready var chop_rest = get_node("ChopRest")
onready var plate_transfer = get_node("PlateTransfer")
onready var recipe_complete = get_node("RecipeComplete")
onready var tutorial_complete = get_node("TutorialComplete")

var plate_item = null

func _ready():
  welcome.get_node("VBoxContainer/Continue").grab_focus()
  pass

func _on_Welcome_Continue_pressed():
  if step != 0 or not is_running:
    return

  welcome.hide()
  Main.order().start(0)
  new_order.show()
  Main.world().get_node("Tutorial/GrabBowlPlateHere").show()
  step += 1

func _on_Cabinet_closed(cabinet):
  if step != 1 or not is_running:
    return

  Main.world().get_node("Tutorial/GrabBowlPlateHere").hide()
  cabinet.disconnect("closed", self, "_on_Cabinet_closed")
  new_order.hide()
  drop_bowl_here.show()
  drop_plate_here.show()
  grab_ingredients.show()
  Main.world().get_node("Tutorial/Ingredients").show()
  Objects.connect("item_added", self, "_on_bowl_plate_drop")
  step += 1

func _on_bowl_plate_drop(_id, cell, item):
  if cell == Vector2(0, -1) and (item is ItemContainer):
    drop_bowl_here.hide()
  if cell == Vector2(1, -1) and (item is ItemContainer):
    drop_plate_here.hide()
  
  if "Plate" in item.name:
    plate_item = item
  
  if not drop_bowl_here.visible and not drop_plate_here.visible:
    Objects.disconnect("item_added", self, "_on_bowl_plate_drop")

func _on_Fridge_closed(fridge):
  if step != 2 or not is_running:
    return

  fridge.disconnect("closed", self, "_on_Fridge_closed")
  Main.world().get_node("Tutorial/Ingredients").hide()
  grab_ingredients.hide()
  chop_lettuce.show()
  Main.world().get_node("Tutorial/ChopLettuce").show()
  Objects.connect("item_added", self, "_on_lettuce_item_added")
  step += 1

func _on_lettuce_item_added(_id, cell, item):
  if step != 3 or not is_running:
    return

  if cell == Vector2(-1, -3) and item is Ingredient:
    Objects.disconnect("item_added", self, "_on_lettuce_item_added")
    Main.world().get_node("Tutorial/ChopLettuce").hide()
    Objects.connect("item_chopped", self, "_on_lettuce_item_chopped")
    step += 1

func _on_lettuce_item_chopped(item):
  if step != 4 or not is_running:
    return

  if item is Ingredient and item.get_chop() == Ingredient.Chop.Chopped:
    Objects.disconnect("item_chopped", self, "_on_lettuce_item_chopped")
    chop_lettuce.hide()
    grab_lettuce_now.show()
    Objects.connect("item_taken", self, "_on_lettuce_item_taken")
    Main.world().get_node("Tutorial/ChopLettuce").show()
    step += 1

func _on_lettuce_item_taken(item):
  if step != 5 or not is_running:
    return

  if item is Ingredient:
    item.chop_percent = 50 # Force so its not broken
    grab_lettuce_now.hide()
    Objects.disconnect("item_taken", self, "_on_lettuce_item_taken")
    Main.world().get_node("Tutorial/ChopLettuce").hide()
    chop_rest.show()
    Objects.connect("item_added_to_container", self, "_on_bowl_item_added")
    step += 1

func _on_bowl_item_added(_item, container):
  if step != 6 or not is_running:
    return
  
  print("CHECKING BOWL", container.get_node("Contents").get_child_count())
  if container.get_node("Contents").get_child_count() == 4:
    Objects.disconnect("item_added", self, "_on_bowl_item_added")
    chop_rest.hide()
    plate_transfer.show()

    if plate_item == null:
      print("THE PLATE WASNT SET DOWN")
      return

    plate_item.connect("recipe_complete", self, "_on_recipe_complete")
    step += 1

func _on_recipe_complete(plate):
  if step != 7 or not is_running:
    return
  
  plate.disconnect("recipe_complete", self, "_on_recipe_complete")
  plate_transfer.hide()
  recipe_complete.show()
  Objects.connect("order_sent", self, "_on_order_sent")
  step += 1

func _on_order_sent():
  if step != 8 or not is_running:
    return

  recipe_complete.hide()
  Objects.disconnect("order_sent", self, "_on_order_sent")
  tutorial_complete.show()
  tutorial_complete.get_node("VBoxContainer/Complete").grab_focus()
  step += 1

func _on_complete():
  tutorial_complete.hide()
  is_running = false
