extends Node

var minigame_status: Dictionary = {
	"backpack": false,
	"gobackday1" : false,
	"takoyaki" : false,
	"ChangeTrash" : false
}

var event_flags: Dictionary = {
	"wash_face": false,
	"found_key": false,
	"gobackday1": false,
	"join_club_done": false
}

var day_night = false
var dawn = false
var current_day = 1

var pending_next_scene: String = ""

var play_cutscene_after_lab2 = false
var play_cutscene_after_lab = false

var last_player_pos: Vector2 = Vector2.ZERO 
var load_exact_pos: bool = false
var target_spawn_name: String = ""   
