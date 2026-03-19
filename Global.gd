extends Node

var minigame_status: Dictionary = {
	"backpack": false,
	"gobackday1" : false
}

var event_flags: Dictionary = {
	"wash_face": false,
	"found_key": false,
	"gobackday1": false       
}

var day_night = false

var last_player_pos: Vector2 = Vector2.ZERO 
var load_exact_pos: bool = false
var target_spawn_name: String = ""   
