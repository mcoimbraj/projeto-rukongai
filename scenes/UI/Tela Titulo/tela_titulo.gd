extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	print("Start button pressed") # Replace with function body.


func _on_opcoes_pressed() -> void:
	pass # Replace with function body.


func _on_creditos_pressed() -> void:
	pass # Replace with function body.


func _on_sair_pressed() -> void:
	pass # Replace with function body.
	get_tree().quit()
