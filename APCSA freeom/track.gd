extends Node

class_name Track

@onready var verifications_holder: Node = $VerificationsHolder
@onready var cars_holder: Node = $CarsHolder

var _finished_cars: Array[int] = []
var _race_ended: bool = false

func _ready() -> void:
	var car_index = 1
	for car in cars_holder.get_children():
		if car is Car:
			car.setup(verifications_holder.get_children().size())
			car.set_player_id(car_index)
			car.start_timing()
			car_index += 1
		elif car is Car2:
			car.setup(verifications_holder.get_children().size())
			car.set_player_id(car_index)
			car.start_timing()
			car_index += 1


func _on_track_area_entered(area: Area2D) -> void:
	if _race_ended:
		return
		
	if area is Car or area is Car2:
		if not area.is_race_finished():
			area.hit_boundary()


func _on_finish_line_area_entered(area: Area2D) -> void:
	if _race_ended:
		return
		
	if area is Car or area is Car2:
		if not area.is_race_finished():
			area.lap_completed()

func car_finished(player_id: int) -> void:
	if player_id not in _finished_cars:
		_finished_cars.append(player_id)
		print("Car %d finished in position %d!" % [player_id, _finished_cars.size()])
		
		# Check if all cars have finished
		var total_cars = cars_holder.get_children().size()
		if _finished_cars.size() >= total_cars:
			end_race()

func end_race() -> void:
	_race_ended = true
	print("\n=== RACE FINISHED ===")
	print("Final Results:")
	for i in range(_finished_cars.size()):
		print("%d. Car %d" % [i + 1, _finished_cars[i]])
	
	# Optional: Display game over message
	show_game_over()
	
	# Optional: Wait a moment then reload or go to menu
	await get_tree().create_timer(3.0).timeout
	get_tree().paused = true
	print("Game Over - Press any key to restart")

func show_game_over() -> void:
	# You can create a UI label to show game over message
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER\nRace Complete!"
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.add_theme_color_override("font_color", Color.RED)
	game_over_label.position = Vector2(400, 300)  # Adjust based on your screen size
	game_over_label.size = Vector2(400, 200)
	add_child(game_over_label)
	
func _input(event: InputEvent) -> void:
	if _race_ended and event.is_pressed() and not event.is_echo():
		# Optional: Restart the game when any key is pressed
		get_tree().paused = false
		get_tree().reload_current_scene()
