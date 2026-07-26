extends Control

signal start_game(cards: Array[CardSpec])
signal return_to_menu


func _ready() -> void:
	$Panel/Info.text = "Select a deck."
	$Panel/Button.disabled = true
	
	
	
	$ReturnButton.pressed.connect(return_to_menu.emit)