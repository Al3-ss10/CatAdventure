extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('protagonista'):
		
		if Global.box:
			Global.ListaPowerUp['box'] += 1
		if Global.gomitolo:
			Global.gomitolo = false
		if Global.magnete:Global.magnete=false
		Global.box=true
		queue_free()
