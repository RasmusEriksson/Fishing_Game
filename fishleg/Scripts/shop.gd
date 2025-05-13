extends Sprite2D

@export var slot_base: ShopSlot
@export var slots: Array

@onready var slot_width = slot_base.texture.get_width() * slot_base.scale.x
@onready var slot_height = slot_base.texture.get_height() * slot_base.scale.y
var slot_amount = 3

func wait(seconds :float):
	await get_tree().create_timer(seconds).timeout

func open_shop():
	for i in range(0,slot_amount):
		var new_slot: ShopSlot = slot_base.duplicate()
		add_child(new_slot)
		
		slots.append(new_slot)
		new_slot.slot_count = i + 1
		
		var y_offset = floori(i/4)
		var x_offset = i - (y_offset*4)
		
		new_slot.global_position = slot_base.global_position + Vector2((slot_width + 20)*x_offset,(slot_height + 20)*y_offset)
		
		new_slot.visible = true
	

func _ready() -> void:
	#open_shop()
	pass
	

var time_wait = 0
func _process(delta: float) -> void:
	time_wait += delta
	if time_wait > 1 :
		slot_base.name_text = "yuh"
