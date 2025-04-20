extends CharacterBody2D
class_name Player

@export var normal_speed = 150  
@export var max_balloons = 3  
@export var base_gravity = 400  

@export var score_health_threshold := 200  
@export var score_fire_threshold := 300   

@export var max_player_health := 1000
@export var min_fire_rate := 0.05

@export var balloon_gravity_reduction = 100  
@export var sharp_fall_multiplier = 2.8  
@export var normal_jump_force = 150  

@export var camera_intensity : float = 1.5
@export var camera_duration : float = .5

@onready var player_spr: AnimatedSprite2D = $Player_Spr

@export var HitFlash : ShaderMaterial

@onready var ballon_spot_1: Node2D = $BalloonHolder/Ballon_spot_1
@onready var ballon_spot_2: Node2D = $BalloonHolder/Ballon_spot_2
@onready var ballon_spot_3: Node2D = $BalloonHolder/Ballon_spot_3

@onready var balloon_holder: Node2D = $BalloonHolder
@onready var gun_holder: Node2D = $GunHolder
@onready var camera: Camera2D = $"../Camera2D"

@onready var health_component: HealthComponent = $HealthComponent
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent


var current_gravity = base_gravity  
var current_jump_force = normal_jump_force  

func _ready():
    
    if player_spr and HitFlash:
        player_spr.material = HitFlash.duplicate()
        player_spr.material.set_shader_parameter("flash_color", Color.WHITE) 
    if hit_box_component:
        hit_box_component.hit_received.connect(HandleHitFlash)
        


func _process(delta: float) -> void:
    pass


 
func _physics_process(delta: float) -> void:
    HandleBalloonMechanic()
    HandleMovement(delta)
    HandleShooting()
    move_and_slide()
    update_player_stats()

 
func HandleBalloonMechanic():
    var filled_slots = get_current_filled_balloon_slots()

     
    if filled_slots == 3:
        current_gravity = base_gravity * 0.9   #Floaty
    elif filled_slots == 2:
        current_gravity = base_gravity * 1.2   #Medium Fall Speed
    elif filled_slots == 1:
        current_gravity = base_gravity * 1.6   #Fast Fall Speed
    else:   
        current_gravity = base_gravity * sharp_fall_multiplier  

 
func get_current_filled_balloon_slots() -> int:
    var filled = 0
    if ballon_spot_1.get_child_count() > 0:
        filled += 1
    if ballon_spot_2.get_child_count() > 0:
        filled += 1
    if ballon_spot_3.get_child_count() > 0:
        filled += 1
    return filled


func HandleMovement(delta: float):

    var direction_x = 0
    if Input.is_action_pressed("left"):
        direction_x = -1
    if Input.is_action_pressed("right"):
        direction_x = 1

    velocity.x = direction_x * normal_speed  

     #Jumping
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = -normal_jump_force  

    velocity.y += current_gravity * delta


func HandleShooting():
    if Input.is_action_pressed("fire"):
        gun_holder.HandleShooting(camera, camera_intensity, camera_duration)


func HandleHitFlash():
    if player_spr and HitFlash:
        player_spr.material.set_shader_parameter("flash_value", 1)
        await get_tree().create_timer(0.2).timeout
        player_spr.material.set_shader_parameter("flash_value", 0)


func update_player_stats():
    Global.player_health = health_component.health
    Global.player_max_health = health_component.MAX_HEALTH


    if Global.score - Global.last_health_score >= score_health_threshold:
        if health_component.health < health_component.MAX_HEALTH:
            health_component.health = min(health_component.health + 50,
            health_component.MAX_HEALTH
            )
            
            Global.last_health_score = Global.score
        
    gun_holder.updatestats(score_fire_threshold,min_fire_rate)
    
    


func _on_health_component_dead() -> void:
    Global.GameOver = true
