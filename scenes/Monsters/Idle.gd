extends State

var start_fight = false

func transition():
	if start_fight:
		get_parent().change_state("Dashing")

func _ready():
	await get_tree().create_timer(3).timeout
	start_fight = true
