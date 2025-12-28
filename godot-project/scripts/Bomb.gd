extends Node2D

var velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	sprite.texture = preload("res://assets/bomb.png")