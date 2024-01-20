extends RigidBody3D
class_name ItemBody
var is_gold := false
var is_being_thrown := false

@export var golder: Golder
var rigid_body: RigidBody3D = self

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ItemBody is RigidBody3D: ", self is RigidBody3D)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func turn_gold():
	if golder:
		golder.turn_gold()
	
func throw():
	is_being_thrown = true
	print('being thrown')
	print('collision mask when being thrown: ', collision_mask)

func _on_body_entered(body: Node):
	print("entered body_shape: ", body.name)
	print("layer of that body: ", body.collision_layer)
	print("apple's mask: ", collision_mask)
	if is_being_thrown:
		is_being_thrown = false
		print("HIT!")
		if body.has_method("damage"):
			body.damage()
			print("did damage")

