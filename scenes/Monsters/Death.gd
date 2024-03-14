extends State

func enter():
	super.enter()
	owner.on_death()
	
func transition():
	if not owner.dead:
		get_parent().change_state("IdleFight")	
		
