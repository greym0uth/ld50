extends "res://storage/storage.gd"

func try_take_item():
  var shop_item = Slots.get_child(current_slot).get_child(0)
  if current_slot >= prestock.size() or shop_item == null or Main.get_cash() < shop_item.cost:
    return null

  var item = prestock[current_slot]
  if item != null and Hotbar.can_pickup():
    var new_item = item.instance()
    Hotbar.try_add_item(new_item)
    Main.subtract_cash(new_item.cost)
    return new_item
  return null
