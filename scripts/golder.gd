# Component to turn anything with a model gold, just attach it as a child 
# of the node which has a child mesh
# currently it turns things gold based on a keybind, but I'll probably make it
# signal based soon
extends Node
class_name Golder
@export var gold_texture: Resource
@onready var meshes: Array[Node]
var parent: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	meshes = find_children("*", "MeshInstance3D")
	print("Meshes length: ", len(meshes))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("turn_everything_gold"):
		turn_gold()

func turn_gold():
	for mesh in meshes as Array[MeshInstance3D]:
		for i in mesh.get_surface_override_material_count():
			mesh.set_surface_override_material(i, gold_texture)
