extends RigidBody3D
class_name Pistol
# No reload capabilites at the moment
@export var current_ammo = 6

@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


