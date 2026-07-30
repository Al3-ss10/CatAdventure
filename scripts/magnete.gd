extends Area2D

func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group('protagonista'):
	
		if Global.magnete:
			Global.ListaPowerUp['magnete'] += 1
		if Global.box:
			Global.box = false
		if Global.gomitolo:Global.gomitolo=false
		Global.magnete=true
		queue_free()
