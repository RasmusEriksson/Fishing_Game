extends Node



var All_Fish_Metadata = {
	"Fush" = {
		"Name" = "Fush",
		"Rarity" = "Common",
		
		"Idle_Speed" = 4,
		"Active_Speed" = 7,
		"Turn_Speed" = 5,
		
		"Rotation_Offset" = 180,
		
		"Default_Direction" = Vector2(1,0),
		"Idle_Behavior" = "Turn",
		"Active_Behavior" = "Chase",
		"Idle_Cycle" = Vector2(2.5,5.5)
	}
}

func add_fish_to_data(fish: CharacterBody2D):
	if All_Fish_Metadata.has(fish.name):
		var Metadata: Dictionary = All_Fish_Metadata[fish.name]
		var data: Dictionary = {}
		
		data["name"] = Metadata["Name"]
		data["rarity"] = Metadata["Rarity"]
		
		if Metadata["Idle_Behavior"] == "Turn":
			data["idle"] = "Turn"
			data["idle_speed"] = Metadata["Idle_Speed"]
			
			var rand_dir: int = randi_range(1,2)
			if rand_dir == 2:
				rand_dir = -1
			
			data["direction"] = rand_dir * Metadata["Default_Direction"]
			data["target_dir"] = rand_dir * Metadata["Default_Direction"]
			data["og_dir"] = rand_dir * Metadata["Default_Direction"]
			
			data["turn_speed"] = Metadata["Turn_Speed"]
			data["cycle_length"] = randf_range(Metadata["Idle_Cycle"].x,Metadata["Idle_Cycle"].y)
			data["cycle_timer"] = 0
			
			data["rotation_offset"] = Metadata["Rotation_Offset"]
			
			data["current_state"] = "idle"
		
		if Metadata["Active_Behavior"] == "Chase":
			data["active"] = "Chase"
			data["active_speed"] = Metadata["Active_Speed"]
		#Fish_Data[fish] = data
		return data
	else :
		return null
	
