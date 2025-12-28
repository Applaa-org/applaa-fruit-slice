extends Node2D

@onready var score_label: Label = $UI/ScoreLabel
@onready var lives_label: Label = $UI/LivesLabel
@onready var high_score_label: Label = $UI/HighScoreLabel
@onready var slice_trail: Line2D = $SliceTrail

var score: int = 0
var lives: int = 3
var high_score: int = 0
var combo: int = 0
var is_slicing: bool = false
var slice_points: Array = []
var fruits: Array = []
var bombs: Array = []
var spawn_timer: float = 0.0
var difficulty_timer: float = 0.0
var spawn_rate: float = 2.0
var fruit_speed: float = 200.0
var bomb_chance: float = 0.1

const FRUIT_TYPES = ["apple", "banana", "orange", "watermelon"]

func _ready():
	update_ui()
	load_game_data()
	
	# Set up message listener for data updates
	setup_message_listener()

func setup_message_listener():
	JavaScriptBridge.eval("""
	window.addEventListener('message', function(event) {
		if (event.data.type === 'applaa-game-data-loaded') {
			// Update high score display
			var highScore = event.data.data.highScore || 0;
			var lastPlayerName = event.data.data.lastPlayerName || '';
			document.getElementById('highScoreDisplay').textContent = 'High Score: ' + highScore;
			if (lastPlayerName) {
				document.getElementById('playerNameInput').value = lastPlayerName;
			}
		}
	});
	""")

func load_game_data():
	JavaScriptBridge.eval("""
	window.parent.postMessage({ type: 'applaa-game-load-data', gameId: 'fruit-slice' }, '*');
	""")

func _process(delta: float):
	spawn_timer += delta
	difficulty_timer += delta
	
	# Increase difficulty
	if difficulty_timer > 10.0:
		spawn_rate = max(0.5, spawn_rate - 0.1)
		fruit_speed += 10
		bomb_chance = min(0.3, bomb_chance + 0.02)
		difficulty_timer = 0.0
	
	# Spawn fruits/bombs
	if spawn_timer > spawn_rate:
		spawn_entity()
		spawn_timer = 0.0
	
	# Update entities
	update_fruits(delta)
	update_bombs(delta)
	
	# Handle slicing
	if Input.is_action_just_pressed("slice"):
		start_slice()
	if Input.is_action_pressed("slice"):
		continue_slice()
	if Input.is_action_just_released("slice"):
		end_slice()

func spawn_entity():
	var is_bomb = randf() < bomb_chance
	var entity_scene = preload("res://scenes/Fruit.tscn") if not is_bomb else preload("res://scenes/Bomb.tscn")
	var entity = entity_scene.instantiate()
	
	entity.position = Vector2(randf_range(100, 700), 600)
	entity.velocity = Vector2(randf_range(-100, 100), randf_range(-300, -200))
	
	if not is_bomb:
		entity.fruit_type = FRUIT_TYPES[randi() % FRUIT_TYPES.size()]
		fruits.append(entity)
	else:
		bombs.append(entity)
	
	add_child(entity)

func update_fruits(delta: float):
	for fruit in fruits:
		fruit.position += fruit.velocity * delta
		fruit.velocity.y += 300 * delta  # gravity
		
		if fruit.position.y < -50:
			fruits.erase(fruit)
			fruit.queue_free()
			lose_life()

func update_bombs(delta: float):
	for bomb in bombs:
		bomb.position += bomb.velocity * delta
		bomb.velocity.y += 300 * delta
		
		if bomb.position.y < -50:
			bombs.erase(bomb)
			bomb.queue_free()

func start_slice():
	is_slicing = true
	slice_points.clear()
	slice_trail.clear_points()

func continue_slice():
	if not is_slicing:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	slice_points.append(mouse_pos)
	slice_trail.add_point(mouse_pos)
	
	# Check collisions
	check_slice_collisions()

func end_slice():
	is_slicing = false
	slice_trail.clear_points()
	combo = 0

func check_slice_collisions():
	for fruit in fruits:
		if is_point_in_slice_trail(fruit.position):
			slice_fruit(fruit)
			break
	
	for bomb in bombs:
		if is_point_in_slice_trail(bomb.position):
			game_over()
			break

func is_point_in_slice_trail(point: Vector2) -> bool:
	if slice_points.size() < 2:
		return false
	
	for i in range(slice_points.size() - 1):
		var p1 = slice_points[i]
		var p2 = slice_points[i + 1]
		if point.distance_to(p1) + point.distance_to(p2) < p1.distance_to(p2) + 10:
			return true
	return false

func slice_fruit(fruit):
	fruits.erase(fruit)
	fruit.queue_free()
	score += 1 + combo
	combo += 1
	update_ui()

func lose_life():
	lives -= 1
	if lives <= 0:
		game_over()
	else:
		update_ui()

func game_over():
	# Save score
	save_score()
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func update_ui():
	score_label.text = "Score: %d" % score
	lives_label.text = "Lives: %d" % lives
	high_score_label.text = "High Score: %d" % high_score

func save_score():
	var player_name = Global.player_name if Global.player_name != "" else "Player"
	JavaScriptBridge.eval("""
	window.parent.postMessage({
		type: 'applaa-game-save-score',
		gameId: 'fruit-slice',
		playerName: '""" + player_name + """',
		score: """ + str(score) + """
	}, '*');
	""")