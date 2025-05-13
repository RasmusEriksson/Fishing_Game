extends Node


@onready var camera: Camera2D = %Camera2D
@onready var bait: CharacterBody2D = %Bait

@onready var fish_manager: Node = %Fish_Manager
@onready var gui: CanvasLayer = %Gui
@onready var inventory: Sprite2D = %Gui/Inventory


var game = false
var reel_in = false

var move_direction = 0
const BASE_MOVE_SPEED = 150
const BASE_SINK_SPEED = 70
const BASE_MAX_REEL = 200
const BASE_REEL_ACCELLERATION = 100

var reel_speed = 0

const CAMERA_SPEED = 2.5
var camera_offset = 0

const THROW_LENGTH = 350
const THROW_END = 1

var throw_time = 0
var throw_lerp = false
var throw_reverse = false

@onready var START_POS = bait.global_position
@onready var end_pos = START_POS + Vector2(THROW_LENGTH,50)
@onready var top_point = START_POS + Vector2(THROW_LENGTH/2,-450)

var fish_inventory: Dictionary = {}
var slot_amount = 9

@onready var slot_base: Sprite2D = $%Gui/Inventory/Slot
@onready var slot_width = (slot_base.texture.get_width() * slot_base.scale.x * inventory.scale.x) + 15

func wait(seconds :float):
	await get_tree().create_timer(seconds).timeout

func beizer_lerp(a :Vector2,b :Vector2,c :Vector2,alpha :float):
	var a2 = lerp(a,b,alpha)
	var b2 = lerp(b,c,alpha)
	
	return lerp(a2,b2,alpha)

func insert_fish_into_inventory(fish: CharacterBody2D,data:Dictionary):
	var once = false
	for index in fish_inventory:
		var slot_info = fish_inventory[index]
		if slot_info["fish_visual"] == null and once == false:
			once = true
			var slot: Sprite2D = slot_info["slot"]
			var name_tag:Label = slot.get_node("Name")
			var rarity_tag:Label = slot.get_node("Rarity")
			
			slot_info["fish_visual"] = fish
			slot_info["name"] = data["name"]
			slot_info["rarity"] = data["rarity"]
			
			name_tag.text = data["name"]
			rarity_tag.text = data["rarity"]
			
			slot.add_child(fish)
			fish.scale *= 4
			fish.global_position = slot.global_position - (fish.get_node("Collision").position * fish.scale.x/1.5) * slot.scale
			fish.look_at(fish.global_position + Vector2(1,0))
			
			

func fish_got(fish: CharacterBody2D,data: Dictionary):
	var center_gui: Sprite2D = %Gui/Shine
	var anim_player: AnimationPlayer = %Gui/Shine/AnimationPlayer
	var name_label: Label = %Gui/Shine/Name
	var rarity_label: Label = %Gui/Shine/Rarity
	
	var inventory: Sprite2D = %Gui/Inventory
	var inventory_fish = fish.duplicate()
	insert_fish_into_inventory(inventory_fish,data)
	
	name_label.text = data["name"]
	rarity_label.text = data["rarity"]
	
	center_gui.scale = Vector2(0.513,0.513)
	
	fish.reparent(center_gui)
	fish.global_position = center_gui.global_position - (fish.get_node("Collision").position * fish.scale.x/2) + Vector2(0,15)
	
	anim_player.play("shine_pop_up")
	fish.look_at(fish.global_position + Vector2(1,0))
	await wait(3)
	anim_player.play("shine_go_away")
	
	await wait(2)
	fish.queue_free()
	
	
	
func start_game():
	end_pos = START_POS + Vector2(THROW_LENGTH,50)
	throw_time = 0
	throw_reverse = false
	throw_lerp = true
	game = true
	camera_offset = 150
	
	fish_manager.generate_fish()

func _unhandled_input(event: InputEvent) -> void:
	if game == false and throw_lerp == false:
		if event.is_action_pressed("Base_input"):
			
			start_game()
	elif reel_in == false:
		if event.is_action_pressed("Reel_In"):
			reel_speed = BASE_SINK_SPEED
			reel_in = true
			camera_offset = -150

func _ready() -> void:
	camera.global_position.y = bait.global_position.y - 100
	
	var width_mult = -1
	var height_mult = -1
	
	for i in range(0,slot_amount):
		var new_slot: Sprite2D = slot_base.duplicate()
		inventory.add_child(new_slot)
		new_slot.global_position = inventory.global_position + Vector2(slot_width * width_mult,slot_width * height_mult)
		new_slot.visible = true
		
		fish_inventory[str(i+1)] = {
			"slot" = new_slot,
			"fish_visual" = null,
			"name" = "",
			"rarity" = "",
			}

		if width_mult >= 1:
			width_mult = -1
			height_mult += 1
		else :
			width_mult += 1
		
		

func _process(delta: float) -> void:
	if game == true:
		if throw_lerp == true:
			throw_time += delta
			if throw_time > THROW_END:
				throw_time = THROW_END
				throw_lerp = false
				if throw_reverse == true:
					game = false
					fish_manager.delete_all_fish()
			
			var alpha = throw_time/THROW_END
			if throw_reverse == false:
				bait.global_position = beizer_lerp(START_POS,top_point,end_pos,alpha)
			else :
				bait.global_position = beizer_lerp(end_pos,top_point,START_POS,alpha)
					
		else :
			
			camera.global_position.y = lerp(camera.global_position.y, bait.global_position.y + camera_offset, delta * CAMERA_SPEED)
			
			move_direction = Input.get_axis("Move_Left","Move_Right")
			var movement = Vector2()
			movement.x = BASE_MOVE_SPEED * move_direction
			
			if reel_in == false:
				movement.y = BASE_SINK_SPEED
			else:
				if reel_speed < -BASE_MAX_REEL:
					reel_speed = -BASE_MAX_REEL
				else :
					reel_speed -= BASE_REEL_ACCELLERATION * delta
				movement.y = reel_speed
			
			
			bait.velocity = movement
			bait.move_and_slide()
			
			if reel_in == true and bait.global_position.y < end_pos.y:
				end_pos.x = bait.global_position.x
				throw_time = 0
				reel_in = false
				throw_lerp = true
				throw_reverse = true
