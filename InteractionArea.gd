extends Area2D

# Export variable allows you to change the message directly in the Inspector
@export var interaction_message: String = "Press [E] to talk to the mysterious statue."
# Path to the Label node
@onready var message_label: Label = $CanvasLayer/MessageLabel 
# Define the name of the player group for filtering
const PLAYER_GROUP_NAME = "player"

func _ready():
	# Set the label text from the export variable
	message_label.text = interaction_message
	
	# Hide the label until the player enters
	message_label.visible = false
	
	# Connect the Area2D signals in the script
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _on_body_entered(body: Node2D):
	# Check if the body entering the area is the player
	if body.is_in_group(PLAYER_GROUP_NAME):
		message_label.visible = true
		print("Player entered interaction zone.")

func _on_body_exited(body: Node2D):
	# Check if the body exiting the area is the player
	if body.is_in_group(PLAYER_GROUP_NAME):
		message_label.visible = false
		print("Player left interaction zone.")
