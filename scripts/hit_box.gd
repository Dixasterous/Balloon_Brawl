extends Area2D


@onready var balloon_pop: AudioStreamPlayer2D = $"../BalloonPop"

signal balloon_destroyed  

var player : Player


func _ready() -> void:
    pass

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("player") or area.is_in_group("balloon") or area.is_in_group("no_bullet"):
        return

    if area is HitBoxComponent:
        var hit_box := area as HitBoxComponent
        

        
        BalloonPop()
        get_parent().queue_free()


func BalloonPop():

    var pop_sound = balloon_pop.duplicate()
    pop_sound.name = "TempBalloonPop"  
    get_tree().current_scene.add_child(pop_sound)  
    pop_sound.global_position = balloon_pop.global_position
    pop_sound.play()
    pop_sound.connect("finished", pop_sound.queue_free)


    emit_signal("balloon_destroyed")
