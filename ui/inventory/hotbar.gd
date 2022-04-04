extends GridContainer

onready var slots = [
  $Slot1,
  $Slot2,
  $Slot3,
  $Slot4,
]

var active: bool = true
var current: int = 0

export(Resource) var default_hotbar_item = load("res://ui/inventory/slot_panel.tres")
export(Resource) var active_hotbar_item = load("res://ui/inventory/slot_panel_active.tres")

func _ready():
  slots[current].add_stylebox_override("panel", active_hotbar_item)

func _process(_delta):
  if active:
    if Input.is_action_just_pressed("ui_next_page"):
      slots[current].add_stylebox_override("panel", default_hotbar_item)
      current = (current + 1) % slots.size()
      slots[current].add_stylebox_override("panel", active_hotbar_item)
    if Input.is_action_just_pressed("ui_prev_page"):
      slots[current].add_stylebox_override("panel", default_hotbar_item)
      current = current - 1 % slots.size()
      if current < 0:
        current = slots.size() - 1
      slots[current].add_stylebox_override("panel", active_hotbar_item)


func can_pickup() -> bool:
  var slot = get_open_slot()
  return slot != null

func get_open_slot():
  for slot in slots:
    if slot.get_child_count() == 0: 
      return slot
  return null

func find_slot(item: Node2D):
  for slot in slots:
    if slot.get_child(0) == item: 
      return slot
  return null

func try_add_item(item: Node2D):
  var open_slot = slots[current] 
  if open_slot.get_child_count() > 0:
    open_slot = get_open_slot()
  if open_slot == null:
    return null
  open_slot.add_child(item)
  item.sleeping = true
  item.position = Vector2(24, 24)
  item.get_node("Sprite").scale = Vector2(2, 2)
  return open_slot

func try_drop_item():
  var item = slots[current].get_child(0)
  if item != null:
    slots[current].remove_child(item)
    item.get_node("Sprite").scale = Vector2.ONE
  return item

func get_current_item():
  var slot = slots[current]
  if slot == null:
    return null
  return slot.get_child(0)

func set_active(new_active: bool):
  active = new_active
  if active:
    slots[current].add_stylebox_override("panel", active_hotbar_item)
  else:
    slots[current].add_stylebox_override("panel", default_hotbar_item)

func set_current(new_current: int):
  slots[current].add_stylebox_override("panel", default_hotbar_item)
  current = new_current
  if active:
    slots[current].add_stylebox_override("panel", active_hotbar_item)
