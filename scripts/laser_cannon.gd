extends Node2D
class_name  LaserCannon
@export var damage = 10

signal playerballoon

signal beamstate(state)

var max_dist = 1500
var timer: float = 0.0  
@export var beam_on_time: float = 5.0  
@export var beam_off_time: float = 3.0  
var beam_state: bool = true 

@onready var laser_beam: Sprite2D = $RayCast2D/LaserCenter
@onready var part: GPUParticles2D = $RayCast2D/GPUParticles2D
@onready var raycast: RayCast2D = $RayCast2D  
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var player : Player

var target_position: Vector2 = Vector2.ZERO  


func _ready():
    target_position.x = -max_dist
    timer = beam_on_time 
    laser_beam.scale.x = 0  
    part.emitting = false  
    beam_state = true 
    player = get_node_or_null("/root/Game/Player")
    
    audio_stream_player_2d.play()

func _process(delta: float) -> void:
    beamstate.emit(beam_state)



func _physics_process(delta):
    handle_beam() 
    handle_beam_timing(delta)  


func handle_beam():

    if beam_state:

        var cast_direction = (target_position - global_position).normalized()
        raycast.target_position = global_position + cast_direction * max_dist  


        raycast.enabled = true  
        var hit = raycast.is_colliding()  

        if hit:

            var hit_object = raycast.get_collider()

            if hit_object is Area2D:
                var hit_pos = raycast.get_collision_point()  
                var laser_length = global_position.distance_to(hit_pos)
                laser_beam.scale.x = laser_length  
                part.emitting = true  
                part.global_position = hit_pos  

                    
                if hit_object is HitBoxComponent:
                    if hit_object != BombEnemy:
                        var hit_box := hit_object as HitBoxComponent

                        hit_box.damage(damage)
            else:
                
                part.emitting = false  
                laser_beam.scale.x = max_dist  
        else:
            part.emitting = false 
            laser_beam.scale.x = max_dist  
    else:
        part.emitting = false  
        laser_beam.scale.x = 0  

func handle_beam_timing(delta):
    timer -= delta  
    if beam_state:
        
        if timer <= 0.0:
            beam_state = false  
            audio_stream_player_2d.playing = false  
            timer = beam_off_time  
    else:
       
        if timer <= 0.0:
            beam_state = true  
            audio_stream_player_2d.playing = true  
            if player:
                player.camera.shake(10, beam_on_time)
            timer = beam_on_time  
