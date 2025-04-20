extends RayCast2D

@onready var line_2d: Line2D = $Line2D
@onready var line_2d_2: Line2D = $Line2D2

@onready var casting_particles: GPUParticles2D = $CastingParticles
@onready var collision_particles: GPUParticles2D = $CollisionParticles
@onready var beam_particles: GPUParticles2D = $BeamParticles

var is_casting: bool = false:
    set(value):
        is_casting = value

        beam_particles.emitting = is_casting
        casting_particles.emitting = is_casting

        if is_casting:
            appear()
        else:
            collision_particles.emitting = false
            disappear()

        set_physics_process(is_casting)

var timer: float = 0.0  
var beam_on_time: float = 5.0  
var beam_off_time: float = 3.0  
var beam_state: bool = false  

func _ready() -> void:
    print("Laser cannon initialized.")
    set_physics_process(true)  
    line_2d.points[1] = Vector2.ZERO
    line_2d_2.points[1] = Vector2.ZERO

func _process(delta: float) -> void:
    timer -= delta 

    if beam_state:
       
        if timer <= 0.0:
            beam_state = false  
            timer = beam_off_time  
            is_casting = false  
    else:

        if timer <= 0.0:
            beam_state = true  
            timer = beam_on_time  
            is_casting = true  


    update_beam()

func update_beam() -> void:
    if is_casting:  
        var cast_point = target_position
        force_raycast_update()

        collision_particles.emitting = is_colliding()

        if is_colliding():
            cast_point = to_local(get_collision_point())
            collision_particles.global_rotation = get_collision_normal().angle()
            collision_particles.position = cast_point

        line_2d.points[1] = cast_point
        line_2d_2.points[1] = cast_point


        beam_particles.position = cast_point * 0.5
        beam_particles.global_rotation = (cast_point - beam_particles.position).angle()
        beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5  

func appear() -> void:
    var tween = create_tween()
    tween.tween_property(line_2d, "width", 25, 0.2)
    tween.tween_property(line_2d_2, "width", 50, 0.2)
    casting_particles.emitting = true

func disappear() -> void:
    var tween = create_tween()
    tween.tween_property(line_2d, "width", 0.0, 0.1)
    tween.tween_property(line_2d_2, "width", 0.0, 0.1)
    casting_particles.emitting = false
