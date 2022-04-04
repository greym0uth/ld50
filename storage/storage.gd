extends StaticBody2D

signal opened
signal closed

var default_hotbar_item = load("res://ui/inventory/slot_panel.tres")
var active_hotbar_item = load("res://ui/inventory/slot_panel_active.tres")

export(String) var item_name = "Basic Storage"
export(int) var cost = 0
export(Array, PackedScene) var prestock = []

onready var Slots = get_node("UI/Slots")

onready var Main = get_node("/root/Main")
onready var Player = Main.world().get_node("Player")
onready var Hotbar = Main.ui().get_node("HUD/Hotbar")

var sleeping = false
var current_slot = 0
var is_open = false
var is_just_opened = false

func set_slot(new_slot: int):
  if current_slot < Slots.get_child_count():
    Slots.get_child(current_slot).add_stylebox_override("panel", default_hotbar_item)

  current_slot = new_slot
  if current_slot < 0:
    current_slot = Slots.get_child_count() + 4 + current_slot
  else:
    current_slot = current_slot % (Slots.get_child_count() + 4) # Add 4 for hotbar slots

  if current_slot >= Slots.get_child_count():
    Hotbar.set_current(current_slot - Slots.get_child_count())
    Hotbar.set_active(true)
  else:
    Hotbar.set_active(false)
    Slots.get_child(current_slot).add_stylebox_override("panel", active_hotbar_item)

func find_open(skip_current = false):
  if not skip_current:
    var current = Slots.get_child(current_slot)
    if current.get_child_count() == 0:
      return current
  
  for slot in Slots.get_children():
    if slot.get_child_count() == 0:
      return slot
  
  return null

func can_put() -> bool:
  return find_open(true) != null

func open():
  is_open = true
  is_just_opened = true
  Slots.show()
  Main.lock_player()
  Hotbar.set_active(false)
  emit_signal("opened", self)

func close():
  is_open = false
  Slots.hide()
  Main.unlock_player()
  Hotbar.set_active(true)
  emit_signal("closed", self)

func try_take_item():
  var item = Slots.get_child(current_slot).get_child(0)
  if item != null and Hotbar.can_pickup():
    Slots.get_child(current_slot).remove_child(item)
    Hotbar.try_add_item(item)
    return item
  return null

func try_put_item():
  if not can_put():
    return null

  var item = Hotbar.try_drop_item()
  if item != null:
    var open_slot = find_open(true)
    if open_slot != null:
      item.sleeping = true
      item.position = Vector2(24, 24)
      item.get_node("Sprite").scale = Vector2(2, 2)
      item.get_node("CollisionShape2D").disabled = true
      open_slot.add_child(item)
      return item
  return null

func _ready():
  Slots.get_child(current_slot).add_stylebox_override("panel", active_hotbar_item)
  for slot_number in Slots.get_child_count():
    if prestock.size() <= slot_number:
      break

    var item = prestock[slot_number].instance()
    item.sleeping = true
    item.position = Vector2(24, 24)
    item.get_node("Sprite").scale = Vector2(2, 2)
    item.get_node("CollisionShape2D").disabled = true
    Slots.get_child(slot_number).add_child(item)

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
    if current_slot < Slots.get_child_count():
      try_take_item()
    else:
      try_put_item()
  if Input.is_action_just_pressed("ui_cancel"):
    close()
