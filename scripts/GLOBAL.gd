extends Node
#Config Menu
var look_sensitivity = 0.25

#Save System
var save_path = "user://save_game_dat"

var game_data : Dictionary = {
	"player_pos" : 3,
	"buildings" : {
		
	}
}


func _ready():
	load_game()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func save_game():
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_var(game_data)
	save_file = null
	

func load_game():
	if FileAccess.file_exists(save_path):
		var save_file = FileAccess.open(save_path, FileAccess.READ)
		game_data = save_file.get_var()
		save_file = null
