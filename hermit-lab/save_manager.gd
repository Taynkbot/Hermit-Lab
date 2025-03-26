extends Node

const SAVE_PATH = "user://savegame.json"

var save_data = {
	"persistent_data": {},  # Data that stays across runs
	"temporary_data": {}    # Data that resets on death
}

# Save game data to a file
func save_game():
	# Get the player node from the group "player"
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Save the player's global position as a Dictionary
		save_data["persistent_data"]["player_position"] = {
			"x": player.global_position.x,
			"y": player.global_position.y
		}

	# Save the data to the file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))  # Pretty-print for debugging
		file.close()
		print("Game saved with player position:", player.global_position)
	else:
		print("Error: Unable to save game.")

# Load game data from a file
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found! Starting fresh.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	# Debugging: Print the raw save file content
	print("Raw save file content:", content)

	# Create an instance of the JSON parser
	var json = JSON.new()
	var json_result = json.parse(content)

	# Check if the parsing was successful
	if json_result == OK:
		save_data = json.get_data()
		print("Game loaded successfully:", JSON.stringify(save_data, "\t"))

		# Restore the player's position if it exists in the save data
		var player = get_tree().get_first_node_in_group("player")
		if player and "player_position" in save_data["persistent_data"]:
			var position = save_data["persistent_data"]["player_position"]
			if typeof(position) == TYPE_DICTIONARY and position.has("x") and position.has("y"):
				player.global_position = Vector2(position["x"], position["y"])
				print("Player position restored:", player.global_position)
			else:
				print("Error: Invalid player position data in save file.")
		else:
			print("Warning: Player node not found or player position missing in save data.")
	else:
		print("Error parsing save file:", json.get_error_message())

# Reset only temporary data (called on death)
func reset_on_death():
	save_data["temporary_data"] = {}  # Clear temp data
	save_game()

func _ready():
	print("SaveManager is ready!")

# Handle key inputs for saving and loading
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):  # Save the game when "K" is pressed
		save_game()
	elif event.is_action_pressed("load_game"):  # Load the game when "L" is pressed
		load_game()
