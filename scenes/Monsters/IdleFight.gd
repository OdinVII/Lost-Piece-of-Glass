extends State

@onready var dash_cooldown = $"../../DashTimer"
var go_walking = false

func enter():
	super.enter()
	owner.sprite.play("idle")
	await get_tree().create_timer(1.5).timeout
	go_walking = true
	
func transition():
	if owner.direction_full.length() > 100 and go_walking:
		#print("PIPISKA1")
		if dash_cooldown.time_left == 0:
			go_walking = false
			get_parent().change_state("Dashing")
		#else: 
			#get_parent().change_state("Walking")
	if go_walking:
		go_walking = false
		get_parent().change_state("Walking")
