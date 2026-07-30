extends Area2D



func _on_body_entered(body: Node2D) -> void:
		if body.is_in_group("protagonista") and Global.MoneteCorrenti >=15 :
			Global.MoneteCorrenti = 0
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
