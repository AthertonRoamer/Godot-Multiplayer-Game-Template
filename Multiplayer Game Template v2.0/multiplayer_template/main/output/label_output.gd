class_name LabelOutput
extends Output

var label : RichTextLabel

func put(message) -> void:
	if is_instance_valid(label):
		label.text += "" + str(message) + "\n"
	else:
		super(message)
