extends Camera2D

@export var shake_intensity: float = 10.0  
@export var shake_duration: float = 0.5   
@export var decay_rate: float = 0.5  
@export var max_shake_intensity: float = 10.0 

var shake_timer: float = 0.0
var original_position: Vector2
var accumulated_intensity: float = 0.0 

func _ready():
    original_position = position  

func _process(delta):
    if shake_timer > 0:
        shake_timer -= delta
        
        position = original_position + Vector2(randf_range(-accumulated_intensity, accumulated_intensity), randf_range(-accumulated_intensity, accumulated_intensity))
    else:
        position = original_position  

    
    if accumulated_intensity > 0:
        accumulated_intensity = max(0, accumulated_intensity - decay_rate * delta) 

func shake(intensity: float, duration: float):
    
    accumulated_intensity = 0.0
    
   
    accumulated_intensity = min(accumulated_intensity + intensity, max_shake_intensity)
    

    shake_timer = max(shake_timer, duration)
