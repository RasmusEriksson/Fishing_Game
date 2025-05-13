extends CharacterBody2D

@onready var game_manager: Node = %Game_Manager
@onready var fish_manager: Node = %Fish_Manager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_aggro_radius_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area != null:
		fish_manager.fish_detection(area.get_parent(),true)


func _on_aggro_radius_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area != null:
		fish_manager.fish_detection(area.get_parent(),false)

func _on_catch_radius_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area != null:
		fish_manager.fish_caught_bait(area.get_parent())
