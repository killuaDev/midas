@tool
extends CharacterBody3D
 
@export var held_item: Pistol
@export var effective_range := 10
@export var health := 5
var is_golden := false
@export var player: Player:
	set(new_player):
		player = new_player
		update_configuration_warnings()

@onready var raycast = $RayCast3D
@onready var aggro_timer = $AggroTimer
@onready var golder: Golder = $golder

func _get_configuration_warnings():
	var warnings: Array[String] = []
	if !player:
		warnings.append("Please select a player")
	return warnings

enum State {
	OutOfRange,
	InRange,
	Shooting
}
var state := State.OutOfRange

# Called when the node enters the scene tree for the first time.
func _ready():
	held_item.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	held_item.freeze = true
	print("Time left on ready: ", aggro_timer.time_left)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !Engine.is_editor_hint():
		if is_golden:
			return
		#TODO: the state machine can be refactored with a class now I'd say
		match state:
			State.OutOfRange:
				look_at(player.camera.global_position)
				velocity = -transform.basis.z
			State.InRange:
				look_at(player.camera.global_position)
				velocity = Vector3.ZERO
			State.Shooting:
				velocity = Vector3.ZERO
				look_at(player.camera.global_position)
				held_item.shoot(raycast.get_collider())
		move_and_slide()
		
		if global_position.distance_to(player.global_position) < effective_range:
			if state != State.Shooting and state != State.InRange:
				state = State.InRange
				aggro_timer.start()
		elif state != State.OutOfRange:
			state = State.OutOfRange

func damage(amount = health):
	health -= amount
	
	if health <= 0:
		queue_free()

func turn_gold():
	is_golden = true
	golder.turn_gold()
	

func _on_aggro_timer_timeout():
	state = State.Shooting
