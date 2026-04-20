extends Node

class_name Track


func _on_track_area_entered(area: Area2D) -> void:
	if area is Car: area.hit_boundary()


func _on_finish_line_area_entered(area: Area2D) -> void:
	if area is Car: area.lap_completed()
