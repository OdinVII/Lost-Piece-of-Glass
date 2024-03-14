extends State

@onready var walk_timer = $"../../WalkingTimer"
var arrived = false

func enter():
	super.enter()
	owner.walking = true
	walk_timer.start()
	owner.sprite.play("idle")

func exit():
	super.exit()
	owner.walking = false
	owner.can_throw1 = false
	owner.shoot_timer.stop()
	#DashTimer.start()

func transition():
	owner.shoot1(owner.global_position)
	if arrived:
		arrived = false
		get_parent().change_state("IdleFight")

func _on_walking_timer_timeout():
	arrived = true
