extends Node2D

var velocity: Vector2 = Vector2.ZERO
var fruit_type: String = "apple"

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	match fruit_type:
		"apple":
			sprite.texture = preload("res://assets/fruits/apple.png")
		"banana":
			sprite.texture = preload("res://assets/fruits/banana.png")
		"orange":
			sprite.texture = preload("res://assets/fruits/orange.png")
		"watermelon":
			sprite.texture = preload("res://assets/fruits/watermelon.png")