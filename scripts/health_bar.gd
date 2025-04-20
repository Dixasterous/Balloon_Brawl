extends ProgressBar

func _ready() -> void:
    self.max_value = Global.player_max_health

func _process(delta: float) -> void:
    self.value = Global.player_health
