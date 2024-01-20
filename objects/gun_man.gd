extends StaticBody3D

@export var held_item: Pistol

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#TODO: state machine
# - if not in range of player it'll go towards the player
# - if in range it'll shoot
