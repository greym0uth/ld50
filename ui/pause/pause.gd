extends PanelContainer

var is_just_opened = false
func _process(_delta):
  if is_just_opened:
    is_just_opened = false
    return 

  if get_tree().paused and (Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("pause")):
    resume()

func resume():
  get_tree().paused = false
  $Menu.show()
  $Options.hide()
  $Controls.hide()
  hide()

func pause():
  is_just_opened = true
  get_tree().paused = true
  $Options.hide()
  $Controls.hide()
  show()
  $Menu.get_node("Resume").grab_focus()

func quit():
  get_tree().quit()

func _on_Back_pressed():
  $Options.hide()
  $Controls.hide()
  $Menu.show()
  $Menu.get_node("Resume").grab_focus()

func _on_Options_pressed():
  $Menu.hide()
  $Options.show()
  $Options.get_node("Music").grab_focus()


func _on_Controls_pressed():
  $Menu.hide()
  $Controls.show()
  $Controls.get_node("Back").grab_focus()
