extends Physics2DDirectBodyState

func _on_Stick_body_entered(body):
	var test = get_contact_collider_id(body.idx)
	var vec = get_contact_collider_position(test)
