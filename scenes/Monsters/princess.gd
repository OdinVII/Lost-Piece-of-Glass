extends CharacterBody2D

@onready var player1 = get_tree().get_first_node_in_group("PlayerGlobal")
@onready var sprite = $AnimatedSprite2D
@onready var dashing_destinations = $places_to_dash_to_player
@onready var collision = $CollisionShape2D
@onready var ghost_timer = $DashingTailTimer
@onready var dashing_timer = $DashTimer

@onready var dashing_sfx = $DashingSound
@onready var knife_thrw_sfx = $KnifeThrowSFX
@onready var going_to_throw_sfx = $GoingToThrow1SFX
@onready var progress_bar = $UI/ProgressBar

@export var ghost_sprite = preload("res://scenes/Monsters/princess_dash_ghost.tscn")

var dashing_dests_array = []
var choosed_to_dash = false
var dashing = false
var dash_ended = false

var walking = false

var dashing_dest
var old_velocity

var dashing_speed = 12000
var walking_speed = 5000
var max_dash_steering = 2000
var health = 600
var dead = false
var died_animations_started = false

var direction
var direction_full

var can_throw1 = false
var shooting = true
var near_shooting = false
var knife1 = preload("res://scenes/Projectiles/princess_knife.tscn")
@onready var shoot_timer = $ShootingTimer

func enemy():
	pass

func _on_hit_box_area_entered(area):
	if area.has_signal("damage_projectile"):
		#got_hit_sfx.play()
		health -= 20
		#print(health)
		#print(hit_particles.emitting)
		#hit_particles.global_position = area.global_position
		#hit_particles.restart()
		
		if area.has_method("explode"):
			area.hit_an_enemy.play()
			area.explode()

func _on_shooting_timer_timeout():
	can_throw1 = true
	
func shoot1(pos):
	if shoot_timer.time_left == 0:
		shoot_timer.start()
		await get_tree().create_timer(shoot_timer.wait_time - 0.5).timeout
		going_to_throw_sfx.play()
	if can_throw1:
		var knife_proj = knife1.instantiate()
		knife_proj.global_position = pos
		var monster_projectiles1 = $"../MonsterProjectilesAll"
		monster_projectiles1.add_child(knife_proj)
		
		knife_thrw_sfx.pitch_scale = randf_range(0.87, 1.15)
		knife_thrw_sfx.play()
		sprite.play("throw_knife")
		can_throw1 = false

func _ready():
	for i in dashing_destinations.get_children():
		dashing_dests_array.append(i)
	#dashing_timer.start()

func add_ghost_tail():
	var tail = ghost_sprite.instantiate()
	tail.set_property(position, sprite.scale, sprite.flip_h)
	get_tree().current_scene.add_child(tail)

func _on_dashing_tail_timer_timeout():
	if dashing:
		add_ghost_tail()

func dash_to_player(delta1):
	if dashing and not choosed_to_dash:
		#print("AAAA")
		dashing_dest = dashing_dests_array.pick_random()
		dashing = true
		choosed_to_dash = true
		
	
func seek_steering(desired_destination, speed1):
	var desired_velocity = (desired_destination - global_position).normalized() * speed1
	return (desired_velocity - velocity)

func animations():
	direction = (player1.global_position - global_position).normalized()
	if direction[0] > 0:
		sprite.flip_h = 0
	if direction[0] < 0:
		sprite.flip_h = 1

func check_if_dead():
	if health <= 0:
		dead = true

signal final_moments
func on_death():
	print("bababuy")
	sprite.play("near_death1")
	await sprite.animation_finished
	sprite.play("near_death2")
	await sprite.animation_finished
	
	sprite.material.set_shader_parameter("noiseIntensity", 0.003)
	sprite.material.set_shader_parameter("colorOffsetIntensity",  1.162)
	sprite.material.set_shader_parameter("modulate_strength", 0.308)
	sprite.play("near_death_idle")
	await get_tree().create_timer(3).timeout
	$Smoke1.restart()
	await get_tree().create_timer(1).timeout
	sprite.material.set_shader_parameter("noiseIntensity", 0.001)
	sprite.material.set_shader_parameter("colorOffsetIntensity",  0.167)
	sprite.material.set_shader_parameter("modulate_strength", 0.261)
	
	sprite.play("near_death3")
	await sprite.animation_finished
	sprite.play("near_death3")
	await sprite.animation_finished
	sprite.play("idle")
	await get_tree().create_timer(1).timeout
	health = 600
	dead = false
	final_moments.emit()

func _process(delta): 
	
	if dead and not died_animations_started:
		$FiniteStateMachine.change_state("Death")
		died_animations_started = true
	#if can_throw1:
		#shoot1(global_position)
	check_if_dead()
		
	direction_full = player1.global_position - global_position
	#print(direction_full.length())
	#print(dashing_timer.time_left)
	dashing_destinations.global_rotation = 0
	dashing_destinations.global_position = player1.global_position
	move_and_slide()
	
	progress_bar.value = (health*100)/400
	#print(health)
	animations()
	dash_to_player(delta)
	if dashing:
		
		var steering = Vector2.ZERO
		steering += seek_steering(dashing_dest.global_position, dashing_speed)
		steering = steering.limit_length(max_dash_steering*delta)
		velocity += steering
		velocity = velocity.limit_length(dashing_speed*delta*1.5)
		#print(steering)
		#print(max_dash_steering*delta)
		#print(dashing_speed*delta*1.5)
		#print("final velocity:")
		#print(velocity)
		#print((velocity[0]**2 + velocity[1]**2)**0.5)
		#print()
	elif walking:
		var steering = Vector2.ZERO
		steering += seek_steering(player1.global_position, walking_speed)
		steering = steering.limit_length(max_dash_steering*delta)
		
		velocity += steering
		velocity = velocity.limit_length(walking_speed*delta*1.5)
	else:
		velocity = Vector2.ZERO


#func _on_hit_box_area_entered(area):
	#if area == dashing_dest:
		#dashing = false






