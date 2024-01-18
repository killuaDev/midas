extends RigidBody3D
class_name Pistol
# No reload capabilites at the moment
@export var current_ammo := 6
@export var cooldown := 0.1
@export var max_range := 50
@onready var timer: Timer = $Timer
signal ammo_updated
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func shoot(target: Object):
	if !timer.is_stopped():
		return
	if current_ammo <= 0:
		# TODO: reload / out of ammo indication
		#print("not shooting because of ammo or cooldown")
		#print("Current ammo: ", pistol.current_ammo)
		#print("Is stopped: ", pistol.timer.is_stopped())
		#print("Time left: ", pistol.timer.time_left)
		#print("is paused: ", pistol.timer.is_paused())
		return
	
	
	# Hitting an enemy
	if target and target.has_method("damage"):
		target.damage()
		
	current_ammo -= 1
	ammo_updated.emit(current_ammo)
	timer.start(cooldown)
