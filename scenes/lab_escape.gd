extends Node3D

@onready var win_screen = $HUD/WinScreen
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_win_zone_body_entered(body):
	game_won()

func game_won():
	win_screen.show()
	get_tree().paused = true
