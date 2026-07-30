
extends CharacterBody2D

const SPEED: float = 160.0
const JUMP_VELOCITY: float = -250.0
const MAX_JUMPS: int = 2

# Cooldown in frame (≈ 1s a 60 FPS)
const FIRE_COOLDOWN_FRAMES: int = 60

# Offset di spawn del proiettile rispetto al centro del personaggio (in pixel)
const PROJECTILE_OFFSET_X: float = 12.0
const PROJECTILE_OFFSET_Y: float = -6.0

var jump_count: int = 0
var tempo: int = 0                      # contatore frame per cooldown
var facing_dir: int = 1                 # 1 = verso destra, -1 = verso sinistra

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn: Marker2D = $Spawn
@onready var RaccogliMonete: CollisionShape2D = $raccoglimonete/CollisionShape2D


func _physics_process(delta: float) -> void:
	if not Global.magnete:
		RaccogliMonete.shape.radius=7
	else:
		RaccogliMonete.shape.radius=45

	
	# Gravità (mantengo la tua logica: se usi una funzione custom get_gravity(), ok)
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

	# Doppio salto
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	Global.tempo2 += 1
	tempo+=1
	# Input orizzontale
	var axis := Input.get_axis("move_left", "move_right")
	Global.direction = axis  # se ti serve altrove, lo mantengo

	# Aggiorna la direzione di facing quando c'è input
	if axis != 0:
		var new_facing := int(signf(axis))  # -1 o 1
		if new_facing != facing_dir:
			facing_dir = new_facing
			animated_sprite.flip_h = (facing_dir < 0)

	# Animazioni
	if is_on_floor():
		if axis == 0.0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Movimento orizzontale
	if axis != 0.0:
		velocity.x = axis * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()

	# Sparo
	if Input.is_action_just_pressed("Sparare") and Global.gomitolo and Global.tempo2 > (FIRE_COOLDOWN_FRAMES-20):
		spara_gomitolo()
		Global.tempo2 = 0
		# (Opzionale ma consigliato) reset del cooldown:
		# tempo = 0
	if Input.is_action_just_pressed("Box") and Global.box and tempo > FIRE_COOLDOWN_FRAMES:
		Spawn_box()
		tempo = 0

func spara_gomitolo() -> void:
	var vatia: PackedScene = load("res://scenes/proietile_gomitolo.tscn")
	var drop_instance: Node2D = vatia.instantiate()

	# Aggiungo prima alla scena
	var parent := get_parent()
	parent.add_child(drop_instance)

	# --- SOSTITUZIONE: usa il Marker2D, con fallback al centro del player ---
	if is_instance_valid(spawn):
		drop_instance.global_position = spawn.global_position
	else:
		drop_instance.global_position = global_position
	# -----------------------------------------------------------------------

	# Direzione coerente col facing attuale
	Global.direction = facing_dir
func Spawn_box():
	print('test')
	var vatia = load("res://scenes/box2.tscn")
	var drop_instance = vatia.instantiate()
	drop_instance.position = position  # lo fa spawnare dove si trova l’oggetto
	get_parent().add_child(drop_instance)

	# --- SOSTITUZIONE: usa il Marker2D, con fallback al centro del player ---


	
