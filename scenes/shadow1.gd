extends Area2D

var flipped_s 
signal first_swapping
signal explosion

@onready var swap_sound = $SwappingSoundSFX
@onready var explosion_sound = $ShadowExplosion
@onready var sound1 = $IdleSoundSFX

@onready var sprite = $AnimatedSprite2D
@onready var timer1 = $Timer

var exploded = false
var player1
var player1sprite
var world1
var shadow_projectile

func _ready():
	sound1.play()
	world1 = get_tree().get_first_node_in_group("world")
	player1 = world1.get_node("Player")
	
	shadow_projectile = world1.get_node("ShadowProjectilesAll").get_child(0)
	
	player1.swapping_w_shadow.connect(_on_player_swapping_w_shadow)
	_on_shadow_spawning()
	timer1.start()
	
func _on_shadow_spawning():
	update_animation_tree()
	await sprite.animation_finished
	sprite.play("idle")	
	

func update_animation_tree():
	sprite.stop()
	sprite.play("swapping")

func _on_player_swapping_w_shadow():
	flipped_s = player1.flipped
	if flipped_s == 0:
		sprite.flip_h = 0
	elif flipped_s == -1:
		sprite.flip_h = -1
		
	first_swapping.emit()
	#swap_sound.play()
	
	update_animation_tree()
	await sprite.animation_finished
	sprite.play("idle")
	
	

func _process(_delta):
	if exploded:
		sound1.volume_db -= 0.22
	#if Input.is_action_just_pressed("Special1"):
		#anim_tree["parameters/conditions/swapping"] = true
	#else:
		#anim_tree["parameters/conditions/swapping"] = false

func _on_timer_timeout():
	exploded = true
	first_swapping.emit()
	explosion.emit()
	explosion_sound.play()
	
	sprite.stop()
	sprite.play("explosion")
	$Particles2D.emitting = false
	await sprite.animation_finished
	queue_free()
