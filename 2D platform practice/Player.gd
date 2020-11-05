extends KinematicBody2D

# Constant variables, "configs", if you will
const UP = Vector2(0, -1)
const GRAVITY = 10
const MAXFALLSPEED = 200
const MAXSPEED = 200
const JUMPFORCE = 150
const ACCEL = 20
const FRICT_MULT = 0.3
const JUMP_CAP_EXTENSION = 10
const JUMP_MOM_FRICT = 0.2
const JUMP_FLOOR_EXTENSION = 5
const JUMP_MOMENTUM = 5
const DASHSPEED = 200
const DASHLEN = 10
const DASH_AMOUNT = 1

# Variables to be used in player logic
var motion = Vector2()
var jump_momentum = 0
var facing_right = true
var jump_floor_extension = JUMP_FLOOR_EXTENSION
var dash_vector = Vector2()
var dash_len = DASHLEN
var dash_amount = DASH_AMOUNT

func _ready():
	pass

# Player movement logic
func _physics_process(delta):
	
	# Gravity
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	# Facing direction
	if facing_right:
		$Sprite.scale.x = 1
	else:
		$Sprite.scale.x = -1
	
	# Horizontal movement
	if Input.is_action_pressed("right"):
		motion.x += ACCEL
		if motion.x > MAXSPEED:
			motion.x = MAXSPEED
		facing_right = true
	elif Input.is_action_pressed("left"):
		motion.x -= ACCEL
		if motion.x < -MAXSPEED:
			motion.x = -MAXSPEED
		facing_right = false
	else:
		motion.x = lerp(motion.x, 0, FRICT_MULT)
	
	# Vertical movement
	if is_on_floor():
		jump_floor_extension = JUMP_FLOOR_EXTENSION
		dash_amount = DASH_AMOUNT
	
	# Jump
	if jump_floor_extension > 0:
		jump_floor_extension -= 1
		if Input.is_action_just_pressed("jump"):
			motion.y = -JUMPFORCE
			jump_momentum = JUMP_MOMENTUM
			jump_floor_extension = 0
	else:
		if !Input.is_action_pressed("jump"):
			jump_momentum = 0
		elif motion.y > JUMP_CAP_EXTENSION:
			jump_momentum = lerp(jump_momentum, 0, JUMP_MOM_FRICT)
		motion.y -= jump_momentum
	
	# Dash
	if Input.is_action_just_pressed("dash") && dash_amount > 0:
		dash_vector = Vector2()
		if Input.is_action_pressed("up"):
			dash_vector.y = -1
		elif Input.is_action_pressed("down"):
			dash_vector.y = 1
		if Input.is_action_pressed("left"):
			dash_vector.x = -1
		elif Input.is_action_pressed("right"):
			dash_vector.x = 1
		if dash_vector.length() == 0:
			if facing_right:
				dash_vector.x = 1
			else:
				dash_vector.x = -1
		dash_vector = dash_vector.normalized() * DASHSPEED
		dash_len = DASHLEN
		dash_amount -= 1
	if dash_len > 0:
		motion = dash_vector
		dash_len -= 1
	
	# Collision and movement from built in function
	motion = move_and_slide(motion, UP)
