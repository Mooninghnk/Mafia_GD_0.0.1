extends CharacterBody3D

#Player imports
@onready var head = $Neck/Head
@onready var standing_colision_shape = $standing_colision
@onready var neck = $Neck

@onready var crouch_colison = $crouch_colsion
@onready var ray_cast_3d = $RayCast3D
@onready var camera_3d = $Neck/Head/eyes/Camera3D
@onready var eyes = $Neck/Head/eyes



#states 
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

#vars for speeds
var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0

#headbob
const head_bobbin_sprinting_speed = 22.0
const head_bobbin_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_crouching_intensity = 0.05
const head_bobbin_walkgin_intensity = 0.1
const head_bobbing_sprinting_intensity = 0.2

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

#input vars
var free_look_tilt_amount = 8
const JUMP_VELOCITY = 4.5
var lerp_speed = 10.0
var crouch_depth = -0.5
var direction = Vector3.ZERO
const mouse_sens = 0.10
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 10


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#mouse
		
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
func _physics_process(delta):
	#handeling player movement
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
	
	#crouching
	if Input.is_action_pressed("crouch") and is_on_floor():
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,crouch_depth, delta*lerp_speed)
		standing_colision_shape.disabled = true
		crouch_colison.disabled = false
		
		walking = false
		sprinting = false
		crouching = true
		
		
	elif !ray_cast_3d.is_colliding():
			#standing
		
		standing_colision_shape.disabled = false
		crouch_colison.disabled = true
		head.position.y = lerp(head.position.y,0.0, delta*lerp_speed)
		
		
		
		if Input.is_action_pressed("sprint"):
			#sprinting
			current_speed = sprinting_speed
			walking = false
			sprinting = true
			crouching = false
			
		else:
			#walking
			walking = true
			sprinting = false
			crouching = false
			current_speed = walking_speed
			
	#freelook
	if Input.is_action_pressed("free_look"):
		free_looking = true
		camera_3d.rotation.z = -deg_to_rad(neck.rotation.y*free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta*lerp_speed)
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, delta*lerp_speed)
		
		
	#handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbin_sprinting_speed*delta
	elif walking:
		head_bobbing_current_intensity = head_bobbin_walkgin_intensity
		head_bobbing_index += head_bobbin_walking_speed*delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed*delta
		
	if is_on_floor() && input_dir != Vector2.ZERO :
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0), delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*(head_bobbing_current_intensity), delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x,0.0, delta*lerp_speed)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
