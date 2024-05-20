class_name IPOption
extends Button

signal selected(option : IPOption)

var ip : String

func _ready():
	update()
	
	
func update() -> void:
	text = "Server : " + ip
	

func _on_pressed():
	selected.emit(self)
