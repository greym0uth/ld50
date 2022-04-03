extends StaticBody2D

export(Resource) var default_hotbar_item = load("res://ui/inventory/slot_panel.tres")
export(Resource) var active_hotbar_item = load("res://ui/inventory/slot_panel_active.tres")

onready var Slots = get_node("UI/Slots")

onready var Main = get_node("/root/Main")
onready var Player = Main.world().get_node("Player")
onready var Hotbar = Main.ui().get_node("HUD/Hotbar")

var current_slot = 0
var is_open = false
var is_just_opened = false

func set_slot(new_slot: int):
  Slots.get_child(current_slot).add_stylebox_override("panel", default_hotbar_item)
  current_slot = new_slot
  if current_slot < 0:
    current_slot = Slots.get_child_count() + current_slot
  else:
    current_slot = current_slot % Slots.get_child_count()

  Slots.get_child(current_slot).add_stylebox_override("panel", active_hotbar_item)

func find_open():
  var current = Slots.get_child(current_slot)
  if current.get_child_count() == 0:
    return current
  
  for slot in Slots.get_children():
    if slot.get_child_count() == 0:
      return slot
  
  return null

func open():
  is_open = true
  is_just_opened = true
  Slots.show()
  get_tree().paused = true

func close():
  is_open = false
  Slots.hide()
  get_tree().paused = false


func _ready():
  Slots.get_child(current_slot).add_stylebox_override("panel", active_hotbar_item)
  for slot in Slots.get_children():
    var item = slot.get_child(0)
    if item != null:
      item.sleeping = true
      item.position = Vector2(24, 24)
      item.get_node("Sprite").scale = Vector2(2, 2)
      item.get_node("CollisionShape2D").disabled = true

func _process(_delta):
  if not is_open:
    return

  if is_just_opened:
    is_just_opened = false
    return

  if Input.is_action_just_pressed("ui_left"):
    if current_slot % 4 == 0:
      set_slot(current_slot + 3)
    else:
      set_slot(current_slot - 1)
  if Input.is_action_just_pressed("ui_right"):
    if (current_slot + 1) % 4 == 0:
      set_slot(current_slot - 3)
    else:
      set_slot(current_slot + 1)
  if Input.is_action_just_pressed("ui_down"):
    set_slot(current_slot + 4)
  if Input.is_action_just_pressed("ui_up"):
    set_slot(current_slot - 4)
  
  if Input.is_action_just_pressed("ui_accept"):
    var item = Slots.get_child(current_slot).get_child(0)
    if item != null and Hotbar.can_pickup():
      Slots.get_child(current_slot).remove_child(item)
      Hotbar.try_add_item(item)
  if Input.is_action_just_pressed("drop"):
    var item = Hotbar.try_drop_item()
    if item != null:
      item.sleeping = true
      item.position = Vector2(24, 24)
      item.get_node("Sprite").scale = Vector2(2, 2)
      item.get_node("CollisionShape2D").disabled = true
      var open_slot = find_open()
      if open_slot != null:
        open_slot.add_child(item)
  if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_cancel"):
    print("closing")
    close()
