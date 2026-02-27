extends Node

const SAVE_PATH = "user://savegame.json"

var save_data = {
	"persistent_data": {},  # Data that stays across runs
	"temporary_data": {}    # Data that resets on death
}

# Save game data to a file
func save_game():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_save_data"):
		save_data["persistent_data"]["player"] = player.get_save_data()
	else:
		print("Warning: Player not found or missing get_save_data()")

	# also save any enemies in the scene that implement saving
	var enemies = get_tree().get_nodes_in_group("enemy")
	print("[SaveManager] found ", enemies.size(), " enemies in group 'enemy'")
	var enemies_data = []
	for e in enemies:
		var debug_id = ""
		# check if the object actually declares an enemy_id property
		for prop in e.get_property_list():
			if prop.name == "enemy_id":
				debug_id = e.enemy_id
				break
		print("   enemy node:", e, " enemy_id=", debug_id)
		if e.has_method("get_save_data"):
			enemies_data.append(e.get_save_data())
		else:
			print("   warning: enemy does not have get_save_data")
	if enemies_data.size() > 0:
		save_data["persistent_data"]["enemies"] = enemies_data

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Game saved")



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
		if player and save_data["persistent_data"].has("player"):
			player.load_save_data(save_data["persistent_data"]["player"])
			print("Player state restored")
		else:
			print("Warning: Player or player save data missing")

		# restore enemies by matching id
		if save_data["persistent_data"].has("enemies"):
			print("[SaveManager] saved enemy entries count:", save_data["persistent_data"]["enemies"].size())
			for d in save_data["persistent_data"]["enemies"]:
				var id = ""
				if d.has("id"):
					id = d["id"]
				print("  attempting restore for id:", id, " data:", d)
				if id == "":
					continue
				var found = false
				# find the enemy instance with matching id
				for e in get_tree().get_nodes_in_group("enemy"):
					var debug_eid = ""
					for prop in e.get_property_list():
						if prop.name == "enemy_id":
							debug_eid = e.enemy_id
							break
					print("    checking node", e, "with id", debug_eid)
					if e.has_method("load_save_data"):
						var eid = ""
						for prop in e.get_property_list():
							if prop.name == "enemy_id":
								eid = e.enemy_id
								break
						if eid == id:
							e.load_save_data(d)
							found = true
							break
				if not found:
					print("Warning: no enemy instance matched saved id ", id)
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
