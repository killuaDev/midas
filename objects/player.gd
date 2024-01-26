extends CharacterBody3D
class_name Player

@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 8

@export_subgroup("Weapons")
@export var weapons: Array[Weapon] = []

@export_subgroup("Items")
@export var held_item: PhysicsBody3D
var weapon: Weapon
var weapon_index := 0

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input_mouse: Vector2

var health:int = 100
var gravity := 0.0

var previously_floored := false

var jump_single := true
var jump_double := true

var container_offset = Vector3(1.2, -1.1, -2.75)

var tween:Tween

signal health_updated
signal ammo_updated
signal weapon_picked_up
signal weapon_dropped

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var muzzle = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Muzzle
@onready var container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var sound_footsteps = $SoundFootsteps
@onready var blaster_cooldown = $Cooldown
@onready var held_item_container = $Head/Camera/held_item_container

# Functions

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	weapon = weapons[weapon_index] # Weapon must never be nil
	#initiate_change_weapon(weapon_index)
	print("Player2 collision layer: ", collision_layer)

func _physics_process(delta):
	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement

	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	
	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	container.position = lerp(container.position, container_offset - (applied_velocity / 30), delta * 10)
	
	# Movement sound
	
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
	
	# Landing after jump or falling
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	# Falling/respawning
	
	if position.y < -10:
		get_tree().reload_current_scene()

# Mouse movement
func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func handle_controls(_delta):
	# Mouse capture
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	# Movement
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	# Rotation
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Shooting
	# just_pressed means semi-auto I think
	if Input.is_action_just_pressed("shoot"):
		action_shoot()
	
	# Jumping
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			jump_double = false
			
		if(jump_single): action_jump()
		
	# Weapon switching
	#action_weapon_toggle()
	
	# Picking up items
	if Input.is_action_just_pressed("pick_up"):
		if held_item:
			item_drop()
			held_item = null
		else:
			item_pick_up()
	
	# Basic throwing
	# TODO: there's probably a lot of tuning to do here to make the throws
	# feel right, but I'll leave that for now5
	if Input.is_action_just_pressed("throw"):
		item_throw() # I know it's inconsistent that the keypress isn't included in the function #TODO	

func item_throw():
	if held_item:
		item_drop()
		held_item.global_position = camera.global_position
		held_item.apply_central_impulse(-camera.global_transform.basis.z * 70)
		if held_item.has_method("throw"):
			held_item.throw()
		else:
			print("held item has no throw function")
		held_item = null

func item_drop():
	held_item.reparent(get_parent(), true)
	
	# start processing physics again
	held_item.freeze = false
	if held_item is Pistol:
		weapon_dropped.emit(held_item)

#TODO: refactor more of this to be in the code of the item being picked up?
#TODO: make this work properly with character bodies (enemies)##
func item_pick_up():
	# TODO: make this a better check of whether something can be picked up
	if raycast.get_collider() is RigidBody3D:
		held_item = raycast.get_collider()
		print("picking up ", held_item.name, held_item.get_class())
		held_item.reparent(held_item_container, false)
		held_item.position = Vector3()
		held_item.rotation = Vector3()
		
		# Stop the held item from getting physics processing
		held_item.freeze = true
		
		# Turn the item gold
		if held_item is ItemBody:
			held_item.turn_gold()
		
		if held_item is Pistol:
			var pistol: Pistol = held_item
			weapon_picked_up.emit(pistol)
			ammo_updated.emit(pistol.current_ammo)
	elif raycast.get_collider() is CharacterBody3D:
		var character_body: CharacterBody3D = raycast.get_collider() as CharacterBody3D
		if character_body.has_method("turn_gold"):
			character_body.turn_gold()
		character_body.drop_item()
		var rigid_body = ItemBody.new()
		held_item_container.add_child(rigid_body)
		for child in character_body.get_children():
			child.reparent(rigid_body, false)
		rigid_body.collision_layer = 0b10 # Collision layer 2 = objects
		rigid_body.collision_mask = 0b1001 # Environments and enemies 
		rigid_body.contact_monitor = true
		rigid_body.max_contacts_reported = 2
		held_item = rigid_body
		held_item.position = Vector3()
		held_item.rotation = Vector3()
		held_item.freeze = true
		character_body.queue_free()
		
# Handle gravity
func handle_gravity(delta):	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():		
		jump_single = true
		gravity = 0

# Jumping
func action_jump():
	gravity = -jump_strength
	
	jump_single = false;
	jump_double = true;

# Shooting
func action_shoot():
	if not held_item is Pistol:
		return
	
	var pistol = held_item as Pistol
	#TODO: this should be somewhere else, but it works for now
	raycast.target_position = Vector3(0, 0, -1) * pistol.max_range
	var collider: Object = raycast.get_collider()
	pistol.shoot(collider)
	# TODO: currently unsure how much code should be here and how much code in the
	# pistol.gd script, we'll adjust as needed		

# Take damage
func damage(amount = health):
	
	health -= amount
	health_updated.emit(health) # Update health on HUD
	
	if health <= 0:
		get_tree().reload_current_scene() # Reset when out of health
