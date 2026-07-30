extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if Global.vita <= 0:
		Global.money = 0
		Global.MoneteCorrenti = 0
	else:
		if area.name == "raccoglimonete":
			Global.money += 1
			Global.MoneteCorrenti +=1
			animation_player.play("pick-up")
