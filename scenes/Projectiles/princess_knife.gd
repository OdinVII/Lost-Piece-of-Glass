extends Area2D

@onready var particles = $GPUParticles2D
@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var player1 = get_tree().get_first_node_in_group("PlayerGlobal")
@onready var hit_a_wall = $HitWall
@onready var knife_hit_wall_sfx = $KnifeHitWallSFX

signal hit_something

var vektor_igroka 
var direction
var distance = 0
var speed = 550
var exploded = false

func monster_projectile():
	pass
	
func _ready():
	vektor_igroka = player1.global_position
	direction = (vektor_igroka-global_position).normalized()
	look_at(vektor_igroka)
	
func _process(delta):
	if distance < 1200 and not exploded:
		#if speed > 240:
			#speed -= 1500 * delta
		position += direction * speed * delta
		distance += speed * delta
		if distance >= 1200:
			queue_free()

func explode():
	#particles.emitting = true
	hit_something.emit()
	exploded = true
	sprite.queue_free()
	collision.queue_free()
	$Particles2D.emitting = false
	await get_tree().create_timer(0.5).timeout
	queue_free()

func explode_particles():
	particles.restart()

func _on_body_entered(body):
	if body is TileMap:
		knife_hit_wall_sfx.play()
		hit_a_wall.play()
		particles.restart()
		explode()
