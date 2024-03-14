extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var particles = $Particles2D
@onready var on_enemy_parts = $OnEnemyParticles
@onready var explode_on_enemy = $OnEnemyExplode
@onready var lights = $PointLight2D
@onready var player1 = get_tree().get_first_node_in_group("PlayerGlobal")
@onready var timer = $Timer
@onready var sound1 = $IdleSoundSFX

var speed: int = 400
var vektor_mishki 
var direction
var distance = 0
static var count = 0
static var pulyki = []

var hit_an_enemy = false
var hit_tilemap = false
var exploding = false

var enemy

func _ready():
	vektor_mishki = get_global_mouse_position()
	direction = (vektor_mishki-global_position).normalized()
	look_at(vektor_mishki)

func anim_explosion():
	#sprite.stop()
	exploding = true
	#$SwappingSoundSFX.play()
	sprite.play("explosion")
	#$ShadowExplosion.play()
	await sprite.animation_finished
	queue_free()

func insta_explosion():
	hit_tilemap = true
	exploding = true
	$ShadowExplosion.play()
	sprite.play("explosion")
	await sprite.animation_finished
	queue_free()

func _process(delta):
	if exploding and hit_an_enemy:
		sound1.volume_db -= 0.14
	player1.red_swapping.connect(anim_explosion)
	
	if distance < 150 and not hit_an_enemy and not hit_tilemap:
		position += direction * speed * delta
		distance += speed * delta
		if distance >= 150:
			particles.emitting = false
			insta_explosion()
	if hit_an_enemy:
		global_position = enemy.global_position
		
func _on_enemy_entered(body):
	if body.has_method("enemy") and not hit_an_enemy:
		sound1.play()
		timer.start()
		hit_an_enemy = true
		enemy = body
		on_enemy_parts.emitting = true
		explode_on_enemy.emitting = true
		lights.enabled = true
	if body is TileMap:
		insta_explosion()


func _on_timer_timeout():
	if not exploding:
		insta_explosion()
