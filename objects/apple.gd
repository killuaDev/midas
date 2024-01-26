extends RigidBody3D

var is_gold := false
var is_being_thrown := false

@onready var golder: Golder = $golder
 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func turn_gold():
	golder.turn_gold()
	
func throw():
	is_being_thrown = true

func _on_body_entered(body):

	if is_being_thrown:
		is_being_thrown = false
	
		if body.has_method("damage"):
			body.damage()


