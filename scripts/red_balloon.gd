extends AnimatedSprite2D
class_name  Balloon

signal balloon_destroyed

@onready var health_component: HealthComponent = $HealthComponent
@onready var balloon_pop: AudioStreamPlayer2D = $BalloonPop
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent


func _ready() -> void:
    
    pass
    


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func BalloonPop():
    balloon_destroyed.emit() 
   
    var pop_sound = balloon_pop.duplicate()
    pop_sound.name = "TempBalloonPop"  
    get_tree().current_scene.add_child(pop_sound)  
    pop_sound.global_position = balloon_pop.global_position
    pop_sound.play()
    pop_sound.connect("finished", pop_sound.queue_free)


func _on_hit_box_component_hit_received() -> void:
    BalloonPop()
