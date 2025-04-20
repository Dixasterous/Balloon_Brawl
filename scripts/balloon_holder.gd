extends Node2D

@export var balloon: PackedScene

@onready var ballon_spot_1: Node2D = $Ballon_spot_1
@onready var ballon_spot_2: Node2D = $Ballon_spot_2
@onready var ballon_spot_3: Node2D = $Ballon_spot_3

var spots: Array[Node2D] = []
var max_balloons := 3

func _ready() -> void:
    spots = [ballon_spot_1, ballon_spot_2, ballon_spot_3]
    connect_all_balloon_signals()

func _process(delta: float) -> void:

    if Input.is_action_just_pressed("add_balloon"):
        add_balloon()
    if Input.is_action_just_pressed("remove_balloon"):
        remove_balloon()

    
    connect_all_balloon_signals()

func connect_all_balloon_signals():
    for i in range(spots.size()):
        var spot = spots[i]
        if spot.get_child_count() > 0:
            var balloon_node = spot.get_child(0)
            var callable = Callable(self, "_on_balloon_destroyed").bind(i)
            if not balloon_node.is_connected("balloon_destroyed", callable):
                balloon_node.connect("balloon_destroyed", callable)


func get_available_spot_index() -> int:
    for i in range(spots.size()):
        if spots[i].get_child_count() == 0:
            return i
    return -1


func add_balloon():
    var available_index = get_available_spot_index()
    if available_index == -1:
        return  

    var new_balloon = balloon.instantiate()
    spots[available_index].add_child(new_balloon)
    new_balloon.get_node("HitBoxComponent").add_to_group("balloon")

    
    if available_index == 1:
        new_balloon.rotate(deg_to_rad(22.3))
    elif available_index == 2:
        new_balloon.rotate(deg_to_rad(-18.3))


func remove_balloon():
    for i in range(spots.size() - 1, -1, -1):
        if spots[i].get_child_count() > 0:
            HandleBalloonRemove(i)
            break


func HandleBalloonRemove(spot_index: int):
    var spot = spots[spot_index]
    if spot.get_child_count() == 0:
        return

    var balloon_node = spot.get_child(0)
    var global_pos = balloon_node.global_position
    spot.remove_child(balloon_node)

    var balloon_container = get_node("/root/Game/BalloonContainer")
    balloon_container.add_child(balloon_node)
    balloon_node.global_position = global_pos
    balloon_node.rotation_degrees = 0

    var tween = get_tree().create_tween()
    tween.tween_property(balloon_node, "position", balloon_node.position + Vector2(0, -500), 1.0)
    tween.tween_callback(Callable(balloon_node, "queue_free"))


func _on_balloon_destroyed(spot_index: int):
    HandleBalloonRemove(spot_index)
