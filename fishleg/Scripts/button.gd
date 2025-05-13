extends Button

var open = false
@onready var closed_sprite: Sprite2D = self.get_node("Closed")
@onready var open_sprite: Sprite2D = self.get_node("Open")
@onready var inventory: Sprite2D = %Inventory

func _pressed() -> void:
	if open == false:
		closed_sprite.visible = false
		open_sprite.visible = true
		open = true
		inventory.open_close(open)
		
	else :
		closed_sprite.visible = true
		open_sprite.visible = false
		open = false
		inventory.open_close(open)
