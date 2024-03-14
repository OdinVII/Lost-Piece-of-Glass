extends Area2D

@onready var particles = $GPUParticles2D
@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

@onready var hit_an_enemy = $HitAnEnemy
@onready var hit_a_wall = $HitWall

signal damage_projectile
signal hit_something

var vektor_mishki 
var direction
var distance = 0
var speed = 700

func _ready():
	vektor_mishki = get_global_mouse_position()
	direction = (vektor_mishki-global_position).normalized()
	look_at(vektor_mishki)
	
func _process(delta):
	if distance < 1200:
		if speed > 240:
			speed -= 1500 * delta
		position += direction * speed * delta
		distance += speed * delta
		if distance >= 1200:
			queue_free()

func explode():
	#particles.emitting = true
	hit_something.emit()
	sprite.queue_free()
	collision.queue_free()
	await get_tree().create_timer(1).timeout
	queue_free()


func _on_body_entered(body):
	if body is TileMap:
		hit_a_wall.play()
		particles.restart()
		explode()
