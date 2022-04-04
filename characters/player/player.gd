extends KinematicBody2D

const ItemContainer = preload("res://containers/item_container.gd")
const Storage = preload("res://storage/storage.gd")

export(int) var speed = 64
export(int) var interactor_offset = 14

onready var Main = get_node("/root/Main")
onready var Hotbar = Main.ui().get_node("HUD/Hotbar")
onready var Objects = Main.world().get_node("Layers/Objects")
onready var Items = Main.world().get_node("Layers/Items")

var velocity = Vector2.ZERO

var current_object = null
var current_storage = null
var itemsCanPickup = []

func _physics_process(_delta):
  if Main.is_player_locked():
    return

  var direction = Vector2.ZERO

  if Input.is_action_pressed("move_forward"):
    direction.y -= 1
  if Input.is_action_pressed("move_backward"):
    direction.y += 1
  if Input.is_action_pressed("move_left"):
    direction.x -= 1
  if Input.is_action_pressed("move_right"):
    direction.x += 1
  
  if direction != Vector2.ZERO:
    direction = direction.normalized()
    if direction.x > 0 or direction.x < 0:
      $AnimatedSprite.animation = "right"
      if direction.x < 0:
        $AnimatedSprite.scale.x = -1
      else:
        $AnimatedSprite.scale.x = 1
    elif direction.y > 0:
      $AnimatedSprite.animation = "down"
    elif direction.y < 0:
      $AnimatedSprite.animation = "up"
    $Interactor.position = direction * interactor_offset

  velocity.x = direction.x * speed
  velocity.y = direction.y * speed

  velocity = move_and_slide(velocity)

func _process(_delta):
  if Main.is_player_locked():
    return

  if Input.is_action_just_pressed("interact"):
    if current_storage:
      current_storage.open()
    elif current_object:
      var current_item = Hotbar.get_current_item()
      if current_item != null and (not Objects.is_busy(current_object) or Objects.is_container(current_object)):
        drop_at_current()
      elif Objects.can_take(current_object) and Hotbar.can_pickup():
        var item = Objects.try_take_item(current_object)
        if item != null:
          if Hotbar.try_add_item(item):
            print("Item was picked up from object")
        else:
          print("IDk what happened the item is gone now")
      pass
    elif itemsCanPickup.size() > 0:
      var item = itemsCanPickup.pop_front()
      item.get_parent().remove_child(item)
      if Hotbar.try_add_item(item) != null:
        item.rotation = 0
        print("Added to inventory")
  
  if Input.is_action_just_pressed("drop"):
    if current_object != null:
      print("trying to place item in ", current_object)
      if not Objects.is_busy(current_object):
        drop_at_current()
    else:
      var item = Hotbar.try_drop_item()
      if item != null:
        Items.add_child(item)
        item.global_position = $Interactor.global_position
        item.get_node("CollisionShape2D").disabled = false


func drop_at_current():
  var item = Hotbar.get_current_item()
  if Objects.from_key(current_object)[0] == 25 and not item is ItemContainer:
    return
  # If were holding a container and the object is a container we want to transfer so dont drop hotbar item.
  if not (item is ItemContainer and Objects.is_container(current_object)):
    item = Hotbar.try_drop_item()
  else:
    print("ITEM IS A CONTAINER TYRING TO TRANSFER")
  if item != null:
    Objects.try_add_item(item, current_object)

func _on_Interactor_body_entered(body: Node2D):
  if body is Storage:
    current_storage = body
  else:
    var cellv = body.world_to_map($Interactor.global_position)
    var tile = body.get_cellv(cellv)
    current_object = Objects.to_key(tile, cellv)

func _on_Interactor_body_exited(body: Node2D):
  if body is Storage and body == current_storage:
    current_storage = null
  else:
    current_object = null

func _on_PickupRadius_body_entered(body: Node2D):
  itemsCanPickup.push_back(body)

func _on_PickupRadius_body_exited(body: Node2D):
  itemsCanPickup.erase(body)
