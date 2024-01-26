@tool
extends CharacterBody3D
 
@export var held_item: Pistol
@export var effective_range := 10
@export var health := 5
@export var aggro_time := 1
var is_golden := false
@export var player: Player:
	set(new_player):
		player = new_player
		update_configuration_warnings()

@onready var raycast = $RayCast3D
@onready var aggro_timer = $AggroTimer
@onready var golder: Golder = $golder
@onready var mesh: MeshInstance3D = $golder/MeshInstance3D
var material = StandardMaterial3D.new()

func _get_configuration_warnings():
	var warnings: Array[String] = []
	if !player:
		warnings.append("Please select a player")
	return warnings

enum State {
	Unaware,
	OutOfRange,
	InRange,
	Shooting
}
@export var state := State.Unaware

# Called when the node enters the scene tree for the first time.
func _ready():
	state = State.Unaware
	held_item.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	held_item.freeze = true
	if can_see_player():
		print("can see player on ready")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !Engine.is_editor_hint():
		if is_golden:
			return
		#TODO: the state machine can be refactored with a class now I'd say
		var ray_target: Node = raycast.get_collider()
		look_at(player.camera.global_position)
		match state:
			State.OutOfRange:
				material.albedo_color = Color(0, 1, 0)
				mesh.set_surface_override_material(0, material)
				velocity = -transform.basis.z
			State.InRange:
				material.albedo_color = Color(1, 1, 0)
				mesh.set_surface_override_material(0, material)
				velocity = Vector3.ZERO
			State.Shooting:
				velocity = Vector3.ZERO
				material.albedo_color = Color(1, 0, 0)
				mesh.set_surface_override_material(0, material)
				if can_see_player():
					held_item.shoot(ray_target)
			State.Unaware:
				pass
					
		move_and_slide()
		
		if global_position.distance_to(player.global_position) < effective_range && can_see_player():
			if state != State.Shooting and state != State.InRange:
				state = State.InRange
				aggro_timer.start(aggro_time)
				print(name, ": Switched to InRange, starting aggro timer")
		elif state != State.OutOfRange && can_see_player():
			state = State.OutOfRange
			print(name, ": switched to OutOfRange")
		elif state != State.Unaware:
			state = State.OutOfRange 

func can_see_player() -> bool:
	return raycast.get_collider() is Player

func damage(amount = health):
	health -= amount
	
	if health <= 0:
		destroy()

func drop_item():
	if !held_item:
		return
		
	held_item.reparent(get_parent_node_3d())
	held_item.freeze = false
	held_item = null

func destroy():
	drop_item()
	queue_free()

func turn_gold():
	is_golden = true
	golder.turn_gold()
	

func _on_aggro_timer_timeout():
	state = State.Shooting
	print(name, ": switched to Shooting")
	
