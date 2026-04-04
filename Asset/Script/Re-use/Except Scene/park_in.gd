extends Node2D

@onready var takoyaki_node = $Takoyaki

func _ready():
	print(Global.minigame_status["takoyaki"])
	setup_events()
	
func setup_events():
	var check = Global.minigame_status["takoyaki"]
	
	if takoyaki_node:
		
		if check == true:
			takoyaki_node.visible = check
		else :
			takoyaki_node.queue_free()
