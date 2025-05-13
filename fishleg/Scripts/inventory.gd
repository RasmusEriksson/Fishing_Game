extends Sprite2D

@onready var animation_player:AnimationPlayer = self.get_node("AnimationPlayer")
var check_open = false

func wait(seconds :float):
	await get_tree().create_timer(seconds).timeout

func open_close(open):
	check_open = open
	if open == false:
		animation_player.play_backwards("pop_up")
		await wait(0.4)
		if check_open == false:
			visible = false
			animation_player.play("RESET")
	else :
		visible = true
		animation_player.play("pop_up")
		
