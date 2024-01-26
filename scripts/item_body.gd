extends RigidBody3D
class_name ItemBody
var is_gold := false
var is_being_thrown := false

@export var golder: Golder
var rigid_body: RigidBody3D = self

# Called when the node enters the scene tree for the first time.
func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if sleeping:
		is_being_thrown = false

func turn_gold():
	if golder:
		golder.turn_gold()
	
func throw():
	print(name, " being thrown")
	is_being_thrown = true

func _on_body_entered(body: Node):
	print(name, " collided with ", body)
	if is_being_thrown:
		if body.has_method("damage"):
			body.damage()
			is_being_thrown = false


