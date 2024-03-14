extends CharacterBody2D

@onready var player1 = get_tree().get_first_node_in_group("PlayerGlobal")

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CharacterBody2D
@onready var hitbox = $Hitbox
@onready var hit_particles = $GPUParticles2D
@onready var zone1 = $Area2D
@onready var got_hit_sfx = $GotHitSFX
@onready var dead_sfx = $DeadSFX

var speed = 2100
var idle_speed = 1200
var health = 60
var dead = false

var chase_player = false

var idling_direction 
var time_of_idling
var walk_or_wait = 1

func enemy():
	pass

func random_idling():
	idling_direction = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
	time_of_idling = randf_range(1,3)

func reducing_idling_time(time1):
	time_of_idling -= time1
	if walk_or_wait < 0.3:
		time_of_idling -= time1 * 0.4
	
func _ready():
	random_idling()
	
	
func walking_animations():
	if dead:
		return
	if velocity == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("run")
		
func _on_area_2d_body_entered(body):
	if player1 == body and not dead:
		chase_player = true

func _on_area_2d_body_exited(body):
	if player1 == body and not dead:
		chase_player = false

func check_if_death():
	if health <= 0 and not dead:
		dead_sfx.play()
		dead = true
		velocity = Vector2.ZERO
		sprite.stop()
		sprite.play("death")
		
		z_index = -1
		collision.queue_free()
		hitbox.queue_free()

func _process(delta):
	#print(chase_player)
	if player1.dead:
		chase_player = false
	
	walking_animations()
	
	if not chase_player and not dead:
		if time_of_idling > 0:
			reducing_idling_time(delta)
		else:
			random_idling()
			walk_or_wait = randf()
		if walk_or_wait >= 0.3:	
			velocity = idling_direction * idle_speed * delta
		else:
			velocity = idling_direction * 0 * delta
		
		if idling_direction[0] > 0:
			sprite.flip_h = 0
		if idling_direction[0] < 0:
			sprite.flip_h = 1
	
	check_if_death()	
	if chase_player and not dead:
		var direction = (player1.global_position - global_position).normalized()
		if direction[0] > 0:
			sprite.flip_h = 0
		if direction[0] < 0:
			sprite.flip_h = 1
		velocity = direction * speed * delta
	
	move_and_slide()

func _on_hitbox_area_entered(area):
	if area.has_signal("damage_projectile"):
		got_hit_sfx.play()
		health -= 20
		#print(health)
		#print(hit_particles.emitting)
		hit_particles.global_position = area.global_position
		hit_particles.restart()
		
		if area.has_method("explode"):
			area.hit_an_enemy.play()
			area.explode()
