extends State

@onready var hitbox = $"../../HitBox"
@onready var final_dest
@onready var DashTimer = $"../../DashTimer"
var arrived = false

func enter():
	super.enter()
	arrived = false
	owner.dashing = true
	owner.sprite.play("dashing")
	$"../../DashingSound".play()

func exit():
	super.exit()
	owner.dashing = false
	owner.choosed_to_dash = false
	$"../../DashingSound".playing = false
	$"../../DashEndedSound".play()
	#DashTimer.start()

func _on_hit_box_area_entered(area):
	if area == final_dest:
		arrived = true
		#print("OOO")

func transition():
	final_dest = owner.dashing_dest
	if arrived:
		arrived = false
		DashTimer.start()
		get_parent().change_state("IdleFight")
