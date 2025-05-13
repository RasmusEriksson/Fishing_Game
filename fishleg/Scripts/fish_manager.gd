extends Node

@onready var bait: CharacterBody2D = %Bait

@onready var zones: Node = %Zones
@onready var fish_storage: Node = preload("res://Scenes/fish_storage.tscn").instantiate()
@onready var game_manager: Node = %Game_Manager

var fish_array = []
var Fish_Data: Dictionary = {}
var detected_fish = []

var fish_caught = false
var caught_fish: CharacterBody2D = null

var fish_amount = 7



func _ready() -> void:
	pass # Replace with function body.

func fish_detection(fish: CharacterBody2D,is_seeing):
	if fish_caught == false:
		if is_seeing == true:
			if not detected_fish.has(fish):
				detected_fish.append(fish)
		else :
			if detected_fish.has(fish):
				detected_fish.remove_at(detected_fish.find(fish))

func fish_caught_bait(fish: CharacterBody2D):
	if fish_caught == false:
		fish_caught = true
		caught_fish = fish

func generate_fish():
	for zone: Area2D in zones.get_children():
		for i in range(0,fish_amount):
			var fish = fish_storage.get_node("Fush").duplicate()
			var zone_size = zone.get_node("Bound_Box").get_shape().get_size()
			fish.global_position = zone.global_position + Vector2(randi_range(zone_size.x/2,zone_size.x/-2),randi_range(zone_size.y/2,zone_size.y/-2))
			
			Fish_Data[fish] = await fish_storage.add_fish_to_data(fish)
			
			fish_array.append(fish)
			add_child(fish)
			
			
func delete_all_fish():
	if fish_caught == true:
		var data = Fish_Data[caught_fish]
		fish_array.remove_at(fish_array.find(caught_fish))
		game_manager.fish_got(caught_fish,data)
		
	for fish in fish_array:
		fish.queue_free()
	fish_array = []
	fish_caught = false
	caught_fish = null

func _process(delta: float) -> void:
	for fish: CharacterBody2D in fish_array:
		var data: Dictionary = Fish_Data[fish]
		
		if data != {}:
			var turn_fish := func fish_turn():
				var angle = lerp_angle(data["direction"].angle(),data["target_dir"].angle(),data["turn_speed"] * delta)
				data["direction"] = data["direction"].from_angle(angle)
				fish.look_at(fish.global_position + data["direction"])
				
				var up_deg_check = 0
				if data.has("rotation_offset"):
					fish.rotate(deg_to_rad(data["rotation_offset"]))
					up_deg_check += data["rotation_offset"]
						
				if up_deg_check/2 > rad_to_deg(angle):
					fish.get_node("Sprite").flip_v = true
				else:
					fish.get_node("Sprite").flip_v = false
			
			
			if fish == caught_fish:
				var fish_move = (bait.global_position - fish.global_position)
				
				data["target_dir"] = fish_move.normalized()
				data["direction"] = fish_move.normalized()
				await turn_fish.call()
				
				fish.velocity = fish_move * 15
				fish.move_and_slide()
				
			elif detected_fish.find(fish) >= 0 and fish_caught == false:
				
				data["current_state"] = "active"
				
				if data["active"] == "Chase":
					
					data["target_dir"] = (bait.global_position - fish.global_position).normalized()
					
					await turn_fish.call()
					
					Fish_Data[fish] = data
					fish.velocity = data["direction"] * data["active_speed"] * 10
					fish.move_and_slide()
			else :
				if data["current_state"] == "active":
					data["target_dir"] = data["og_dir"]
					data["current_state"] = "idle"
					
				if data["idle"] == "Turn":
					data["cycle_timer"] += delta
					if data["cycle_timer"] >= data["cycle_length"]:
						data["target_dir"] *= -1
						data["cycle_timer"] = 0
					
					await turn_fish.call()
					
					Fish_Data[fish] = data
					fish.velocity = data["direction"] * data["idle_speed"] * 10
					fish.move_and_slide()
