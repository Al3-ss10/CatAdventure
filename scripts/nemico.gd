extends Node2D
var SPEED = 20
var direction = 1
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var nemico: RigidBody2D = $"."
@onready var uccisione: AudioStreamPlayer2D = $uccisione
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var nascita_eseguita = false
var pavimento = 0
var morte = 0

func nascita():
	if nascita_eseguita == false:
		SPEED = 0
		animated_sprite_2d.play("nascita")
		await animated_sprite_2d.animation_finished
		SPEED = 20
		animated_sprite_2d.play("default")
		nascita_eseguita = true
	else:
		pass

func Morte():
	animated_sprite_2d.play("morte")
	SPEED = 0
	uccisione.play()
	await animated_sprite_2d.animation_finished
	queue_free()
	Global.flag = true

# Funzione pubblica che un altro nemico può chiamare per forzarci a invertire
func inverti_direzione_forzata():
	direction *= -1
	animated_sprite_2d.flip_h = direction == -1

func _physics_process(delta: float) -> void:
	nascita()
	
	ray_cast_up.force_raycast_update()
	ray_cast_down.force_raycast_update()
	ray_cast_right.force_raycast_update()
	ray_cast_left.force_raycast_update()
	
	if ray_cast_up.is_colliding():
		Morte()
		return
	
	var ostacolo_laterale = false
	
	if direction == 1 and ray_cast_right.is_colliding():
		ostacolo_laterale = true
	if direction == -1 and ray_cast_left.is_colliding():
		ostacolo_laterale = true
	
	# Se colpiamo un nemico, invertiamo noi E forziamo lui a invertire
	if direction == 1 and ray_cast_right.is_colliding():
		var corpo = ray_cast_right.get_collider()
		if corpo != null and corpo.is_in_group("enemy"):
			ostacolo_laterale = true
			if corpo.has_method("inverti_direzione_forzata"):
				corpo.inverti_direzione_forzata()
	if direction == -1 and ray_cast_left.is_colliding():
		var corpo = ray_cast_left.get_collider()
		if corpo != null and corpo.is_in_group("enemy"):
			ostacolo_laterale = true
			if corpo.has_method("inverti_direzione_forzata"):
				corpo.inverti_direzione_forzata()
	
	var niente_pavimento = not ray_cast_down.is_colliding()
	
	if ostacolo_laterale or niente_pavimento:
		direction *= -1
		animated_sprite_2d.flip_h = direction == -1
	
	position.x += direction * SPEED * delta
