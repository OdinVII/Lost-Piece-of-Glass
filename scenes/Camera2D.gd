extends Camera2D

var randomStrenght = 4.0
var shakeFade = 40.0

var rng = RandomNumberGenerator.new()

var shake_strength = 0.0
var shaking1 = false
var shaking2 = false
@onready var timer = $ShakeTimer
@onready var timer2 = $ShootShakeTimer


func apply_shake():
	shake_strength = randomStrenght

func shaking_on_signal():
	shaking1 = true
	timer.start()

func shaking_on_shooting():
	shaking2 = true
	timer2.start()

func _process(delta):
	$"..".shooting_signal.connect(shaking_on_shooting)
	$"..".suitcase_hit_something.connect(shaking_on_signal)
	if shaking1:
		#if Input.is_action_just_pressed("shoot_normal"):
		apply_shake()
		
		if shake_strength > 0:
			shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		
		offset = randomOffset()
	
	if shaking2:
		#if Input.is_action_just_pressed("shoot_normal"):
		apply_shake()
		
		if shake_strength > 0:
			shake_strength = lerpf(shake_strength * 0.4,0,shakeFade * delta)
		
		offset = randomOffset()
		
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength),rng.randf_range(-shake_strength,shake_strength))


func _on_shake_timer_timeout():
	shaking1 = false

func _on_shoot_shake_timer_timeout():
	shaking2 = false
