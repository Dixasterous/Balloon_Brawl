extends Node2D
class_name Gun

@export var damage := 10
@export var Gun_Sprite: Sprite2D
@export var bullet: PackedScene
@export var bullet_spawn: Node2D


func _ready() -> void:
        
    Gun_Sprite.scale = Vector2(2.5,2.5)
    Gun_Sprite.offset.x = 4.25
    

func _process(delta: float) -> void:
    pass


func spawn():
    if bullet and Gun_Sprite:
        var shot = bullet.instantiate()
        get_parent().add_child(shot)
        shot.shoot(bullet_spawn.global_position, get_global_mouse_position())
    else:
        print("Assign bullet and Gun_Sprite in Inspector")



func _on_gun_holder_bullet_spawn() -> void:
    spawn()
