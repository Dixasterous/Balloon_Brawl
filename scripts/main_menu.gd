extends Control

var game = preload("res://scenes/game.tscn")


func _ready() -> void:
    pass





func _on_start_pressed() -> void:
    get_tree().change_scene_to_packed(game)


func _on_quit_pressed() -> void:
    get_tree().quit()
