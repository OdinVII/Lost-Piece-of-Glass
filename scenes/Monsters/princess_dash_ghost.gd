extends AnimatedSprite2D

func _ready():
	ghosting()
	
func set_property(princess_pos, princess_scale, princess_flip_h):
	position = princess_pos
	scale = princess_scale
	flip_h = princess_flip_h

func ghosting():
	var tween_fade = get_tree().create_tween()
	
	tween_fade.tween_property(self, "self_modulate", Color(1,1,1,0), 0.35)
	
	await tween_fade.finished
	
	queue_free()
