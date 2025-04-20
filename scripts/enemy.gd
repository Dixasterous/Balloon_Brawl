extends CharacterBody2D
class_name BombEnemy

@export var fixed_damage: int = 10 
@export var max_explosion_damage: int = 20  
@export var health: float = 100.0
@export var health_component: HealthComponent
@export var hitbox: HitBoxComponent
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var red_balloon: AnimatedSprite2D = $BalloonHolder/RedBalloon

@export var speed: float = 130.0
@export var enemy_spr: Sprite2D

# Explosion Radius and Attack Range
@export var explosion_radius: float = 200.0 
@export var attack_range: float = 100.0  
@export var gravity_strength: float = 500.0  

@onready var explosion: AudioStreamPlayer2D = $Explosion

signal enemy_died



var player: Player
var has_exploded: bool = false  

enum State { FLOATING, FALLING }
var state: State = State.FLOATING

func _ready() -> void:
    health_component.dead.connect(HandleExplosion)

    var balloon_health = red_balloon.get_node("HealthComponent") as HealthComponent
    if balloon_health:
        balloon_health.dead.connect(HandleBalloonDestroy)

    if health_component:
        health_component.health = health

    player = get_node_or_null("/root/Game/Player")

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    match state:
        State.FLOATING:
            if player:
                var direction = (player.position - position).normalized()
                velocity = direction * speed
                move_and_slide()

                var distance_to_player = position.distance_to(player.position)
                if distance_to_player < attack_range: 
                    if distance_to_player < explosion_radius: 
                        var distance_factor = (explosion_radius - distance_to_player) / explosion_radius * 2
                        var scaled_damage = round(max_explosion_damage * distance_factor)
                        player.health_component.damage(scaled_damage)
                    explode(player)

        State.FALLING:
            #velocity.x = 0
            velocity.y += gravity_strength * delta  
            move_and_slide()
            if Player:
                var distance_to_player = position.distance_to(player.position)
                if distance_to_player < attack_range:  
                        if distance_to_player < explosion_radius:  
                            var distance_factor = (explosion_radius - distance_to_player) / explosion_radius * 2
                            var scaled_damage = round(max_explosion_damage * distance_factor)
                            player.health_component.damage(scaled_damage)
                        explode(player)
                if is_on_floor():
                    if player:
                        explode(player)

func explode(target: Player):
    if has_exploded:
        return
    has_exploded = true

    if target:
       

        
        var distance_to_player = position.distance_to(target.position)

        
        if distance_to_player < explosion_radius: 
            var distance_factor = (explosion_radius - distance_to_player) / explosion_radius * 2
            var scaled_damage = round(max_explosion_damage * distance_factor)
            target.hit_box_component.damage(scaled_damage)
        else:
           
            pass
        
        health_component.died() 
        


    

func HandleExplosion():
    if player:
        explode(player)
    Explosion()
    gpu_particles_2d.get_parent().remove_child(gpu_particles_2d)
    get_tree().root.add_child(gpu_particles_2d)
    gpu_particles_2d.global_position = global_position
    gpu_particles_2d.emitting = true
    player.camera.shake(5, 0.5)  

func HandleBalloonDestroy():
    state = State.FALLING

func Explosion():
    enemy_died.emit()
    var explosion_sound = explosion.duplicate()
    explosion_sound.name = "TempBalloonPop"  
    get_tree().current_scene.add_child(explosion_sound)  
    explosion_sound.global_position = explosion.global_position
    explosion_sound.play()
    explosion_sound.connect("finished", explosion_sound.queue_free)
