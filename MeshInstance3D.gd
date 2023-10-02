extends Node3D

var mouse_mov
var sway_tresh = 10
var sway_lerp = 10

@export var sway_left : Vector3
@export var sway_right: Vector3
@export var sway_normal: Vector3



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_mov != null:
		if mouse_mov > sway_tresh:
			rotation = rotation.lerp(sway_left, sway_lerp * delta)
		elif mouse_mov < -sway_tresh:
			rotation = rotation.lerp(sway_right, sway_lerp * delta)
		else:
			rotation = rotation.lerp(sway_normal, sway_lerp * delta)
