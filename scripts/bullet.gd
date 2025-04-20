extends Area2D


var direction = Vector2.ZERO

@export var speed = 1000
@export var damage = 10

@export var die_timer = 5

@onready var bullet_spr: Sprite2D = $Sprite2D

@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


func shoot(start_pos: Vector2 , target_pos: Vector2):
    position = start_pos
    direction = (target_pos - start_pos).normalized()
    rotation = direction.angle() # rotate bullet to match the mouse pos
    set_as_top_level(true) # frees from parents transformations
    timer.start(die_timer)
    
    
func _physics_process(delta: float) -> void:
    position += direction * speed * delta
    

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("player") or area.is_in_group("balloon") or area.is_in_group("no_bullet"):
        return

    if area is HitBoxComponent:
        var hit_box := area as HitBoxComponent
        hit_box.damage(damage)
        queue_free()


  


func _on_timer_timeout() -> void:
    queue_free()
