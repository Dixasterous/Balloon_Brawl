extends Control

@onready var score: Label = $VBoxContainer/Score



func _ready() -> void:
 score.text  = 'Score: '+str(Global.score)





func _on_reset_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/game.tscn")
