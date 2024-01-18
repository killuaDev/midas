extends RigidBody3D

var is_gold := false
var is_being_thrown := false

@onready var golder: Golder = $golder
 
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Apple Collision Layer: ", collision_layer)
	print("Apple collision mask: ", collision_mask)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func turn_gold():
	golder.turn_gold()
	
func throw():
	is_being_thrown = true
	print('being thrown')
	print('collision mask when being thrown: ', collision_mask)

func _on_body_entered(body):
	print("entered body_shape: ", body.name)
	print("layer of that body: ", body.collision_layer)
	print("apple's mask: ", collision_mask)
	if is_being_thrown:
		is_being_thrown = false
		print("HIT!")
		if body.has_method("damage"):
			body.damage()
			print("did damage")

