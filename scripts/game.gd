extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var enemy_spawn_timer: Timer = $Enemy_Spawn
@onready var difficulty_timer: Timer = $DifficultyTimer
@onready var laser_spawn_timer: Timer = $LaserSpawnTimer  
@onready var score_timer: Timer = $ScoreTimer


@export var bomb_enemy = preload("res://scenes/bomb_enemy.tscn")
@export var laser_cannon = preload("res://scenes/laser_cannon.tscn")


@onready var laser_cannon_spawn_pos: Node2D = $LaserCannonSpawnPos

# Difficulty settings
@export var initial_wait_time: float = 2.0  
@export var decay_rate: float = 0.98  
var time_passed: float = 0.0  

# Laser spawn settings
@export var initial_laser_wait_time: float = 3.0  
@export var laser_decay_rate: float = 0.95  

@export var score_multiplier := 25.0  

var laser_time_passed: float = 0.0  
var can_spawn_laser : bool
var can_move = false
func _ready():
    Global.score = 0
    Global.last_health_score = 0
    Global.last_fire_score = 0
    Global.player_health =0
    Global.player_max_health = 1000
    Global.GameOver = false
   
    can_spawn_laser = false
    enemy_spawn_timer.wait_time = initial_wait_time
    laser_spawn_timer.wait_time = initial_laser_wait_time  
    laser_spawn_timer.paused = true 
    
    enemy_spawn_timer.autostart = true 
    difficulty_timer.autostart = true  
    
    laser_spawn_timer.start()
    

func _process(delta: float) -> void:
    if Global.GameOver == true:
        get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("esc"):
        get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_enemy_spawn_timeout() -> void:
    var enemy_pos = Vector2(randf_range(-800, 900), randf_range(-600, 185))

    while (enemy_pos.x > -750 and enemy_pos.x < 850) and (enemy_pos.y > -450 and enemy_pos.y < 200):
        enemy_pos = Vector2(randf_range(-800, 900), randf_range(-600, 185))

    var spawn = bomb_enemy.instantiate()
    spawn.position = enemy_pos
    add_child(spawn)  

    
    if enemy_spawn_timer.wait_time < 1.0:
        can_spawn_laser = true
        laser_spawn_timer.paused = false


func _on_difficulty_timer_timeout() -> void:
    time_passed += difficulty_timer.wait_time  

   
    var new_wait_time = initial_wait_time * pow(decay_rate, time_passed)
    
   
    new_wait_time = max(new_wait_time, 0.2)

    
    enemy_spawn_timer.wait_time = new_wait_time

 


func _on_laser_spawn_timer_timeout() -> void:
    if can_spawn_laser:

        laser_time_passed += laser_spawn_timer.wait_time

        var new_laser_wait_time = initial_laser_wait_time * pow(laser_decay_rate, laser_time_passed)
        new_laser_wait_time = max(new_laser_wait_time, 0.5)
        laser_spawn_timer.wait_time = new_laser_wait_time

        spawn_laser_cannon()




func spawn_laser_cannon() -> void:
    var spawn_spots = laser_cannon_spawn_pos.get_children()
    var available_spots = []
    var current_laser_count = 0


    for spot in spawn_spots:
        if spot.get_child_count() > 0:
            current_laser_count += 1
        else:
            available_spots.append(spot)


    var max_lasers = 0
    if enemy_spawn_timer.wait_time < 0.25:
        max_lasers = 3
    elif enemy_spawn_timer.wait_time < 0.5:
        max_lasers = 2
    elif enemy_spawn_timer.wait_time < 1.0:
        max_lasers = 1




    var allowed_to_spawn = max_lasers - current_laser_count
    if allowed_to_spawn <= 0:
        pass  
    else:

        var lasers_to_spawn = min(allowed_to_spawn, available_spots.size())

        for i in range(lasers_to_spawn):
            var spot_index = randi() % available_spots.size()
            var random_spawn = available_spots[spot_index]
            available_spots.remove_at(spot_index)

            var laser = laser_cannon.instantiate()
            random_spawn.add_child(laser)
            laser.global_position = random_spawn.global_position
            laser.global_rotation = random_spawn.global_rotation

    # --- RANDOMLY MOVE EXISTING LASERS (25% chance) ---
    for spot in spawn_spots:
        if spot.get_child_count() > 0:
            var laser = spot.get_child(0)
            
            var callable = Callable(self, "_on_beam_on").bind()
            if not laser.is_connected("beamstate", callable):
                laser.connect("beamstate", callable)

            if randf() < 0.10 and can_move:
                print('burh')

                var empty_spots = []
                for s in spawn_spots:
                    if s.get_child_count() == 0:
                        empty_spots.append(s)
                if empty_spots.size() > 0:
                    var new_spot = empty_spots[randi() % empty_spots.size()]
                    
                    


                    
                    var tween = get_tree().create_tween()
                    

                    tween.tween_property(laser, "global_position", new_spot.global_position, 0.6).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
                    tween.tween_property(laser, "global_rotation", new_spot.global_rotation, 0.6).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
                    

                    laser.global_rotation = new_spot.global_rotation
                    

func _on_beam_on(is_on: bool):
    can_move = not is_on


func _on_score_timer_timeout() -> void:
    var base_time = max(enemy_spawn_timer.wait_time, 0.1)  
    var score_to_add = score_multiplier / base_time
    Global.score += int(score_to_add)
