class_name OutputStash
extends Output

var messages : Array[String] = []

func put(m) -> void:
	messages.append(m)
	
	
func output_all() -> void:
	for m in messages:
		Main.output(m)
