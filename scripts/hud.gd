extends CanvasLayer

@onready var ammo: Label = $Ammo
@onready var health: Label = $Health

func _on_health_updated(new_health: int):
	health.text = str(new_health) + "%"



func _on_ammo_updated(current_ammo: int):
	ammo.text = "Ammo: " + str(current_ammo)


func _on_weapon_dropped(pistol: Pistol):
	pistol.ammo_updated.disconnect(_on_ammo_updated)
	ammo.hide()


func _on_weapon_picked_up(pistol: Pistol):
	pistol.ammo_updated.connect(_on_ammo_updated)
	ammo.show()
