extends CharacterBody2D

var speed1 = 15000
var speed2 = 13000

var flipped = 0
var shooting = 0
var dead = false
var cutscene = false

var can_swap = true
@onready var shadow_timer = $ShadowTimer
@onready var DeathTimer = $DeathTimer

signal swapping_w_shadow
signal red_swapping

signal suitcase_hit_something
signal shooting_signal

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var run_particles = $Particles2D

@onready var run_sfx = $RunningSFX
@onready var throw_sfx = $Throw

var can_throw1: bool = true
var shadow_type = 1

var can_throw_shadow: bool = true
var shadow_projectile = preload("res://scenes/shadow_projectile.tscn")
@onready var starting_pos = $Throwing_spot
var shadow

var suitcase_projectile = preload("res://scenes/Projectiles/suitcase_projectile.tscn")
var red_shadow_projectile = preload("res://scenes/shadow_2_projectile.tscn")

func _ready():
	dead = false
	$"..".teleport_player.connect(teleport)
	$"..".got_cursed_signal.connect(got_cursed)
	$"../Princess".final_moments.connect(final_death)

func teleport():
	global_position = $"../SpawnPoint".global_position
	var material1 = sprite.material
	material1.set_shader_parameter("range", 0.06)
	material1.set_shader_parameter("noiseQuality", 300)
	material1.set_shader_parameter("colorOffsetIntensity",  0.8)

func change_shadow_type():
	if cutscene:
		return
	if Input.is_action_just_pressed("change_shadow_type"):
		if shadow_type == 1:
			shadow_type = 2
		elif shadow_type == 2:
			shadow_type = 1

func throwing_red_shadow(pos):
	can_swap = true
	var red_shadow_proj = red_shadow_projectile.instantiate()
	red_shadow_proj.global_position = pos
	var shad_world_projectiles2 = $"../RedShadowProjectiles"
	shad_world_projectiles2.add_child(red_shadow_proj)
	
	shadow_timer.start()
	can_throw_shadow = false

func swapping_bodies(body):
	if cutscene:
		return
	if Input.is_action_just_pressed("Special1"):
		$SwappingSoundSFX.play()
		emit_signal("swapping_w_shadow")
		var old_position = global_position
		var body_old_position = body.global_position
		
		body.global_position = Vector2(9999,9999)
		await get_tree().create_timer(0.03).timeout
		
		global_position = body_old_position
		body.global_position = old_position
		if shadow_type == 2:
			red_swapping.emit()

func throwing_suitcase(pos):
	var suitcase_proj = suitcase_projectile.instantiate()
	suitcase_proj.global_position = pos
	var suit_world_projectiles1 = $"../SuitcaseProjectilesAll"
	suit_world_projectiles1.add_child(suitcase_proj)
	#suitcase_proj.hit_something.connect(_on_suitcase_hit)
	
	shooting_signal.emit()
	$SuitcaseTimer.start()
	can_throw1 = false

func check_if_projectiles_explode():
	if len(owner.find_child("SuitcaseProjectilesAll").get_children()) > 0:
		#print("AAAAAAAAAAAA")
		for i in owner.find_child("SuitcaseProjectilesAll").get_children():
			i.hit_something.connect(_on_suitcase_hit)
	if len(owner.find_child("MonsterProjectilesAll").get_children()) > 0:
		for i in owner.find_child("MonsterProjectilesAll").get_children():
			i.hit_something.connect(_on_suitcase_hit)

func _on_suitcase_hit():
	suitcase_hit_something.emit()
	#print("AAAAA")

func throwing_shadow(pos):
	can_swap = true
	var shadow_proj = shadow_projectile.instantiate()
	shadow_proj.global_position = pos
	var shad_world_projectiles1 = $"../ShadowProjectilesAll"
	shad_world_projectiles1.add_child(shadow_proj)
	
	shadow_timer.start()
	can_throw_shadow = false
		
func move(delta, speed):
	if cutscene:
		velocity = Vector2.ZERO
		run_particles.emitting = false
		run_sfx.playing = false
		return
		
	var direction = Input.get_vector("left_move", "right_move", "up_move", "down_move")
	
	velocity = direction * speed * delta
	
	if velocity == Vector2.ZERO:
		run_particles.emitting = false
		run_sfx.playing = false
	else:
		run_particles.emitting = true
		if run_sfx.playing == false:
			run_sfx.playing = true
	move_and_slide()
	
	
func _shooting_ended():
	shooting = 0

func update_animations_tree():
	if shooting == 0:
		if velocity == Vector2.ZERO:
			sprite.play("idle")
		else:
			sprite.play("running")
	
	if cutscene:
		return
	
	if Input.is_action_just_pressed("shoot") and can_throw_shadow:
		throw_sfx.play()
		
		if shadow_type == 1:
			throwing_shadow(starting_pos.global_position)
		elif shadow_type == 2:
			throwing_red_shadow(starting_pos.global_position)
		shooting = 1
		sprite.play("throwing")
		sprite.animation_finished.connect(_shooting_ended)
	elif Input.is_action_just_pressed("shoot_normal") and can_throw1:
		throw_sfx.play()
		
		throwing_suitcase(starting_pos.global_position)
		shooting = 1
		sprite.play("throwing")
		sprite.animation_finished.connect(_shooting_ended)

func _process(delta):
	#print(collision.disabled)
	check_if_projectiles_explode()
	if dead:
		return
		
	change_shadow_type()
	#print(shadow_type)
	
	shadow = $"../Shadow".get_child(0)
	if get_local_mouse_position()[0] < 0:
		sprite.flip_h = -1
		flipped = -1
	if get_local_mouse_position()[0] > 0:
		sprite.flip_h = 0
		flipped = 0
	
	update_animations_tree()
	if Input.is_action_pressed("Run"):
		move(delta,speed2)
	else:
		move(delta,speed1)
	
	if len($"../Shadow".get_children()) == 1:
		var shadow2 = $"../Shadow".get_child(0)
		shadow2.explosion.connect(cant_swap)
		if can_swap == true:
			swapping_bodies(shadow)
	elif len($"../RedShadowProjectiles".get_children()) == 1:
		var red_shadow = $"../RedShadowProjectiles".get_child(0)
		if can_swap == true:
			if red_shadow.hit_an_enemy and not red_shadow.exploding:
				swapping_bodies(red_shadow.enemy)
		
func got_cursed():
	sprite = $Sprite2D2
	$Sprite2D.visible = false
	$Sprite2D2.visible = true

func cant_swap():
	can_swap = false

func _on_timer_timeout():
	can_throw_shadow = true

func _on_suitcase_timer_timeout():
	can_throw1 = true

signal died

func _on_hitbox_body_entered(body):
	if dead:
		return
	if body.has_method("enemy"):
		suitcase_hit_something.emit()
		dead = true
		died.emit()
		
		collision.set_deferred("disabled", true)
		run_particles.emitting = false
		run_sfx.playing = false
		#sprite.stop()
		sprite.play("death")
		#print("dead")
		DeathTimer.start()

func _on_hitbox_area_entered(area):
	if dead:
		return
	if area.has_method("monster_projectile"):
		#print("AAAAAAAAAAAA")
		area.explode_particles()
		area.explode()
		
		suitcase_hit_something.emit()
		dead = true
		died.emit()
		
		#collision.disabled = true
		collision.set_deferred("disabled", true)
		
		run_particles.emitting = false
		run_sfx.playing = false
		#sprite.stop()
		sprite.play("death")
		#print("dead")
		DeathTimer.start()

func got_alive():
	global_position = $"../SpawnPoint".global_position
	dead = false
	await get_tree().create_timer(0.2).timeout
	#collision.disabled = false
	collision.set_deferred("disabled", false)

var finally_died = false
func final_death():
	finally_died = true
func _on_death_timer_timeout():
	if finally_died:
		return
	#print("A")
	got_alive()
