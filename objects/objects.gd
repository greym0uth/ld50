extends TileMap

signal item_added
signal item_added_to_container
signal item_taken
signal item_chopped
signal order_sent

const Ingredient = preload("res://ingredients/ingredient.gd")
const ItemContainer = preload("res://containers/item_container.gd")

onready var Main = get_node("/root/Main")

var items = Dictionary()

func to_key(id: int, cellv: Vector2) -> String:
  return String(id) + " " + String(cellv.x) + "," + String(cellv.y)

func from_key(key: String):
  var split = key.split(" ")
  var id = int(split[0])
  var cv_split = split[1].split(",")
  var cellv = Vector2(int(cv_split[0]), int(cv_split[1]))
  return [id, cellv]

func is_busy(key: String) -> bool:
  if not items.has(key):
    return false

  var item = items[key]
  if item is ItemContainer:
    return item.is_busy()
  else:
    return true

func is_container(key: String) -> bool:
  if not items.has(key):
    return false
  
  return items[key] is ItemContainer

func can_take(key: String) -> bool:
  return items.has(key) 

func try_add_item(item: RigidBody2D, key: String):
  if is_busy(key):
    return null
  
  # If there is a container in the object try adding to that container
  if is_container(key):
    # If were trying to add another container try transfering the contents
    if item is ItemContainer:
      var c = items[key].try_transfer_contents(item)
      if c != null:
        print("Transfered contents to new container")
        return key
      print("Unable to transfer contents to new container")
    elif items[key].try_add_item(item) != null:
      emit_signal("item_added_to_container", item, items[key])
      return key
    return null
  else:
    var parts = from_key(key)
    items[key] = item
    item.sleeping = true
    item.get_node("CollisionShape2D").disabled = true
    item.position = map_to_world(parts[1]) + Vector2(8, 4)
    item.get_node("Sprite").scale = Vector2(0.5, 0.5)
    add_child(item)
    emit_signal("item_added", parts[0], parts[1], item)
    return key

func try_take_item(key: String):
  if can_take(key):
    var item = items[key]
    remove_child(item)
    items.erase(key)
    emit_signal("item_taken", item)
    return item
  else:
    return null

func do_process(id: int, item: Node2D, delta: float, key: String):
  match id:
    19, 20, 21, 22:
      item.do_chop(10 * delta)
      emit_signal("item_chopped", item)
    4:
      if item is ItemContainer:
        item.do_cook(10 * delta)
    23:
      remove_child(item)
      items.erase(key)
      item.queue_free()
    25:
      Main.add_cash(item.current_recipe.value)
      Main.order().complete(item)
      remove_child(item)
      items.erase(key)
      item.queue_free()
      emit_signal("order_sent")
      Main.order().delayed_start()

func _process(delta):
  for key in items.keys():
    var parts = from_key(key)
    do_process(parts[0], items[key], delta, key)
