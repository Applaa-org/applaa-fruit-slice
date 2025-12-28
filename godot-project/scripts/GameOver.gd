extends Control

@onready var final_score_label: Label = $VBoxContainer/FinalScoreLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready():
	final_score_label.text = "Final Score: %d" % Global.score
	high_score_label.text = "High Score: %d" % Global.high_score
	
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_restart_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()