extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var explosionSFX = $ShadowExplosion
var speed: int = 400
var vektor_mishki 
var direction
var distance = 0
static var count = 0
static var pulyki = []
static var shadows = []

var end_distance
var hit_tilemap = false
var inside_hole = false

var shadow_preload = preload("res://scenes/shadow1.tscn")
var shadow

signal shadow_has_spawned

func anim_explosion():
	#sprite.stop()
	sprite.play("explosion")
	if inside_hole:
		explosionSFX.play()
	await sprite.animation_finished
	pulyki[0].queue_free()
	

func spawn_shadow():
	shadow = shadow_preload.instantiate()
	shadows.append(shadow)
	
	shadow.position = global_position
	var world1 = get_tree().get_first_node_in_group("world")
	world1.get_node("Shadow").add_child(shadow)
	
	if len(shadows) > 0:
		shadows[0].first_swapping.connect(anim_explosion)


func _ready():
	pulyki.append(self)
	
	vektor_mishki = get_global_mouse_position()
	direction = (vektor_mishki-global_position).normalized()
	end_distance = global_position.distance_to(vektor_mishki)
	
	
func _process(delta):
	#print(inside_hole)
	if distance < end_distance and distance < 130 and not hit_tilemap:
		
		position += direction * speed * delta
		distance += speed * delta
		
		#print(end_distance)
		#print(distance)
		if distance >= 130 or distance >= end_distance or hit_tilemap:
			#print(hit_tilemap)
			$Particles2D.emitting = false
			if len(pulyki) > 1:
				
				if is_instance_valid(pulyki[0]):
					pulyki[0].queue_free()
				pulyki.remove_at(0)
				
				if len(shadows) > 0:
					if is_instance_valid(shadows[0]):
						shadows[0].queue_free()
					shadows.remove_at(0)
				#$Timer.start()
				#print("0000")
			if not inside_hole:
				spawn_shadow()
			else: 
				anim_explosion()

func _on_timer_timeout():
	self.queue_free()
	#print("AAAAAAAAAAAAAA")

func _on_body_entered(body):
	if body.name == "TileMap":
		#print("zhoopa")
		hit_tilemap = true
		if hit_tilemap:
			#print(hit_tilemap)
			$Particles2D.emitting = false
			if len(pulyki) > 1:		
				if is_instance_valid(pulyki[0]):
					pulyki[0].queue_free()
				if len(shadows) > 0:
					if is_instance_valid(shadows[0]):
						shadows[0].queue_free()
				pulyki.remove_at(0)
				shadows.remove_at(0)
				#$Timer.start()
				#print("0000")
			spawn_shadow()
	if body.name == "TileMap2":
		inside_hole = true
		#print("zhoopa22")


func _on_area_2d_body_exited(body):
	if body.name == "TileMap2":
		#print("BBBB")
		inside_hole = false
