extends Node2D

signal bullet_spawn
@onready var player: CharacterBody2D = $".."

@export var orbit_radius: float = 100  

@export var fire_rate_cooldown: float = 0.5
@export var fire_rate_timer: Timer

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var can_shoot = true  

func _ready() -> void:
    pass



func _process(delta: float) -> void:
    if player:
        var mouse_pos = get_global_mouse_position()
        var angle_to_mouse = (mouse_pos - player.global_position).angle()

        global_position = player.global_position + Vector2(orbit_radius, 0).rotated(angle_to_mouse)

        rotation = angle_to_mouse
        
func HandleShooting(camera,camera_intensity,camera_duration):
    if Input.is_action_pressed("fire") and can_shoot:
        audio_stream_player_2d.play()
        can_shoot = false 
        fire_rate_timer.wait_time = fire_rate_cooldown 
        fire_rate_timer.start()
        bullet_spawn.emit()
        camera.shake(camera_intensity,camera_duration)  


func updatestats(score_fire_threshold,min_fire_rate):
    if Global.score - Global.last_fire_score >= score_fire_threshold:
        if fire_rate_cooldown > min_fire_rate:
            fire_rate_cooldown = max(fire_rate_cooldown - 0.02, min_fire_rate)
            Global.last_fire_score = Global.score


        
func _on_fire_rate_timeout() -> void:
    can_shoot = true  
