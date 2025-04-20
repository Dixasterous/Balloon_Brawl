extends Area2D
class_name HitBoxComponent



@export var health_component: HealthComponent

signal hit_received

func damage(attack):
    if health_component:
        emit_signal("hit_received")  
        health_component.damage(attack)
        
