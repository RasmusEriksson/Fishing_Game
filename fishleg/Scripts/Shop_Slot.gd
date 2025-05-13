class_name ShopSlot

extends Sprite2D



@export var image_name := ""
@export var slot_count := 1
@export var name_text := "woah" :
	set(value):
		var text_tag = $Name
		if text_tag :
			text_tag.text = value

@export var description := "no way amigo!":
	set(value):
		var text_tag = $Description
		if text_tag :
			text_tag.text = value
