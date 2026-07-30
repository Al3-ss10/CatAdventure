extends Area2D

@onready var vita: Node2D = %vita
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	if Global.vita == 1 || Global.vita == 2:
		Global.vita += 1
		print(Global.vita)
		animation_player.play("pickups")
	elif Global.vita ==3:
		Global.ListaPowerUp['polpetta']+=1
		animation_player.play("pickups")
