# StatusFXOverlay: Visual animations overlay for negative status effects
# Rendered dynamically on active Pokemon cards in combat.
class_name StatusFXOverlay
extends Control

# Preloaded animation textures from original game assets
const BURN_FRAMES: Array[Texture2D] = [
	preload("res://assets/fx/status/burn_0.png"),
	preload("res://assets/fx/status/burn_1.png"),
	preload("res://assets/fx/status/burn_2.png"),
	preload("res://assets/fx/status/burn_3.png"),
	preload("res://assets/fx/status/burn_4.png"),
	preload("res://assets/fx/status/burn_5.png"),
	preload("res://assets/fx/status/burn_6.png"),
	preload("res://assets/fx/status/burn_7.png"),
]
const FREEZE_TEX: Texture2D = preload("res://assets/fx/status/freeze.png")
const PARALYZE_FRAMES: Array[Texture2D] = [
	preload("res://assets/fx/status/paralyze_0.png"),
	preload("res://assets/fx/status/paralyze_1.png"),
	preload("res://assets/fx/status/paralyze_2.png"),
	preload("res://assets/fx/status/paralyze_3.png"),
]
const SLEEP_FRAMES: Array[Texture2D] = [
	preload("res://assets/fx/status/sleep_0.png"),
	preload("res://assets/fx/status/sleep_1.png"),
	preload("res://assets/fx/status/sleep_2.png"),
]
const POISON_FRAMES: Array[Texture2D] = [
	preload("res://assets/fx/status/poison_0.png"),
	preload("res://assets/fx/status/poison_1.png"),
	preload("res://assets/fx/status/poison_2.png"),
]
const CONFUSION_TEX: Texture2D = preload("res://assets/fx/status/confusion.png")
const TRAPPED_TEX: Texture2D = preload("res://assets/fx/status/trapped.png")

# Visual child elements
var burn_rect: TextureRect
var freeze_rect: TextureRect
var paralyze_rect: TextureRect
var sleep_rect: TextureRect
var poison_rect: TextureRect
var confusion_rect: TextureRect
var trapped_rect: TextureRect

# Active status flags
var has_burn: bool = false
var has_poison: bool = false
var has_freeze: bool = false
var has_sleep: bool = false
var has_paralyze: bool = false
var has_confusion: bool = false
var has_trapped: bool = false

# Internal animation state timers
var anim_time: float = 0.0
var burn_timer: float = 0.0
var burn_idx: int = 0
var burn_active_timer: float = 0.0
var poison_timer: float = 0.0
var poison_idx: int = 0
var paralyze_active_timer: float = 0.0
var paralyze_frame_timer: float = 0.0
var paralyze_frame_idx: int = 0
var sleep_cycle_time: float = 0.0

func _init() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	clip_contents = false

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	_setup_layers()

func _setup_layers() -> void:
	# 1. Trapped Layer (Web in the back)
	trapped_rect = TextureRect.new()
	trapped_rect.name = "TrappedLayer"
	trapped_rect.texture = TRAPPED_TEX
	trapped_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	trapped_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	trapped_rect.size = Vector2(110, 110)
	trapped_rect.position = Vector2(10, 35)
	trapped_rect.modulate = Color(1.0, 1.0, 1.0, 0.72)
	trapped_rect.mouse_filter = MOUSE_FILTER_IGNORE
	trapped_rect.visible = false
	add_child(trapped_rect)

	# 2. Freeze Layer (Ice Block encasing Pokemon)
	freeze_rect = TextureRect.new()
	freeze_rect.name = "FreezeLayer"
	freeze_rect.texture = FREEZE_TEX
	freeze_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	freeze_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	freeze_rect.size = Vector2(96, 126)
	freeze_rect.position = Vector2(17, 26)
	freeze_rect.modulate = Color(0.9, 0.96, 1.0, 0.84)
	freeze_rect.mouse_filter = MOUSE_FILTER_IGNORE
	freeze_rect.visible = false
	add_child(freeze_rect)

	# 3. Burn Layer (Static Idle Flame Ball)
	burn_rect = TextureRect.new()
	burn_rect.name = "BurnLayer"
	burn_rect.texture = BURN_FRAMES[0]
	burn_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	burn_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	burn_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	burn_rect.size = Vector2(64, 64)
	burn_rect.position = Vector2(33, 58)
	burn_rect.mouse_filter = MOUSE_FILTER_IGNORE
	burn_rect.visible = false
	add_child(burn_rect)

	# 4. Poison Layer (Poison Drop Appearing and Splashing on Pokemon)
	poison_rect = TextureRect.new()
	poison_rect.name = "PoisonLayer"
	poison_rect.texture = POISON_FRAMES[0]
	poison_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poison_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	poison_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	poison_rect.size = Vector2(32, 32)
	poison_rect.pivot_offset = Vector2(16, 16)
	poison_rect.position = Vector2(49, 15)
	poison_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	poison_rect.mouse_filter = MOUSE_FILTER_IGNORE
	poison_rect.visible = false
	add_child(poison_rect)

	# 5. Paralyze Layer (Electric Sparks)
	paralyze_rect = TextureRect.new()
	paralyze_rect.name = "ParalyzeLayer"
	paralyze_rect.texture = PARALYZE_FRAMES[0]
	paralyze_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paralyze_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	paralyze_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paralyze_rect.size = Vector2(72, 52)
	paralyze_rect.position = Vector2(29, 56)
	paralyze_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	paralyze_rect.mouse_filter = MOUSE_FILTER_IGNORE
	paralyze_rect.visible = false
	add_child(paralyze_rect)

	# 6. Confusion Layer (Golden Stars orbiting head)
	confusion_rect = TextureRect.new()
	confusion_rect.name = "ConfusionLayer"
	confusion_rect.texture = CONFUSION_TEX
	confusion_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	confusion_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	confusion_rect.size = Vector2(28, 36)
	confusion_rect.pivot_offset = Vector2(14, 18)
	confusion_rect.position = Vector2(51, 6)
	confusion_rect.mouse_filter = MOUSE_FILTER_IGNORE
	confusion_rect.visible = false
	add_child(confusion_rect)

	# 7. Sleep Layer (Zzz drifting upward)
	sleep_rect = TextureRect.new()
	sleep_rect.name = "SleepLayer"
	sleep_rect.texture = SLEEP_FRAMES[0]
	sleep_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sleep_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sleep_rect.size = Vector2(42, 28)
	sleep_rect.position = Vector2(75, 35)
	sleep_rect.mouse_filter = MOUSE_FILTER_IGNORE
	sleep_rect.visible = false
	add_child(sleep_rect)

func trigger_burn_effect(duration: float = 0.85) -> void:
	burn_active_timer = duration
	burn_idx = 0
	burn_timer = 0.0
	if burn_rect:
		burn_rect.visible = true
		burn_rect.texture = BURN_FRAMES[0]
		burn_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)

func trigger_poison_effect() -> void:
	poison_timer = 0.0
	if poison_rect:
		poison_rect.visible = true
		poison_rect.texture = POISON_FRAMES[0]
		poison_rect.position = Vector2(49, 15)
		poison_rect.scale = Vector2(1.0, 1.0)
		poison_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)

func trigger_paralyze_effect(duration: float = 1.2) -> void:
	paralyze_active_timer = duration
	paralyze_frame_timer = 0.0
	paralyze_frame_idx = 0
	if paralyze_rect:
		paralyze_rect.visible = true
		paralyze_rect.texture = PARALYZE_FRAMES[0]
		paralyze_rect.position = Vector2(29, 56)
		paralyze_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)

func update_statuses(pkmn) -> void:
	if not pkmn or pkmn.current_hp <= 0:
		clear_all()
		return

	has_burn = pkmn.burn_turns > 0
	has_poison = pkmn.is_poisoned
	has_freeze = pkmn.is_frozen
	has_sleep = pkmn.is_asleep_turns > 0
	has_paralyze = pkmn.is_paralyzed
	has_confusion = pkmn.is_confused
	has_trapped = pkmn.is_constricted_dmg > 0

	# Burn and Paralyze are transient (only show when their effect triggers in combat)
	if burn_active_timer <= 0.0 and burn_rect:
		burn_rect.visible = false
	if paralyze_active_timer <= 0.0 and paralyze_rect:
		paralyze_rect.visible = false

	poison_rect.visible = has_poison
	freeze_rect.visible = has_freeze
	sleep_rect.visible = has_sleep
	confusion_rect.visible = has_confusion
	trapped_rect.visible = has_trapped

func clear_all() -> void:
	has_burn = false
	burn_active_timer = 0.0
	has_poison = false
	has_freeze = false
	has_sleep = false
	has_paralyze = false
	paralyze_active_timer = 0.0
	has_confusion = false
	has_trapped = false

	if burn_rect: burn_rect.visible = false
	if poison_rect: poison_rect.visible = false
	if freeze_rect: freeze_rect.visible = false
	if sleep_rect: sleep_rect.visible = false
	if paralyze_rect: paralyze_rect.visible = false
	if confusion_rect: confusion_rect.visible = false
	if trapped_rect: trapped_rect.visible = false

func _process(delta: float) -> void:
	anim_time += delta

	# 1. Burn Animation (static position idle flame ball playing when triggered)
	if burn_active_timer > 0.0 and burn_rect:
		burn_active_timer -= delta
		burn_timer += delta
		if burn_timer >= 0.075:
			burn_timer = 0.0
			burn_idx = (burn_idx + 1) % BURN_FRAMES.size()
			burn_rect.texture = BURN_FRAMES[burn_idx]
		
		# Fade out gently in the last 0.15s of the effect
		if burn_active_timer < 0.15:
			burn_rect.modulate.a = maxf(0.0, burn_active_timer / 0.15)
		else:
			burn_rect.modulate.a = 1.0

		if burn_active_timer <= 0.0:
			burn_rect.visible = false

	# 2. Poison Animation (droplet forming above Pokemon, falling down, and splashing)
	if has_poison and poison_rect:
		poison_timer += delta
		var cycle_len = 2.2
		var t = fmod(poison_timer, cycle_len)
		if t < 0.35:
			# Phase 1: Purple bubble forming above head
			poison_rect.visible = true
			poison_rect.texture = POISON_FRAMES[0]
			poison_rect.position = Vector2(49, 15)
			var appear_t = clampf(t / 0.35, 0.0, 1.0)
			poison_rect.scale = Vector2(appear_t, appear_t)
			poison_rect.modulate.a = appear_t
		elif t < 0.70:
			# Phase 2: Teardrop falling downward onto body (y: 15 -> 65)
			poison_rect.visible = true
			poison_rect.texture = POISON_FRAMES[1]
			var fall_progress = (t - 0.35) / 0.35
			var y_pos = lerpf(15.0, 65.0, fall_progress * fall_progress)
			poison_rect.position = Vector2(49, y_pos)
			poison_rect.scale = Vector2(1.0, 1.15)
			poison_rect.modulate.a = 1.0
		elif t < 1.05:
			# Phase 3: Splash / Splat on the body (y = 65)
			poison_rect.visible = true
			poison_rect.texture = POISON_FRAMES[2]
			poison_rect.position = Vector2(49, 65)
			var splat_progress = (t - 0.70) / 0.35
			poison_rect.scale = Vector2(1.2 + splat_progress * 0.3, 0.9 - splat_progress * 0.2)
			poison_rect.modulate.a = maxf(0.0, 1.0 - splat_progress)
		else:
			# Phase 4: Pause before next drip
			poison_rect.visible = false
	elif poison_rect and not has_poison:
		poison_rect.visible = false

	# 3. Freeze Animation (shimmering crystal)
	if has_freeze and freeze_rect:
		var gleam = 0.72 + 0.22 * (0.5 + 0.5 * sin(anim_time * 3.5))
		freeze_rect.modulate = Color(0.85, 0.95, 1.0, gleam)

	# 4. Paralyze Animation (only triggers when paralysis actively blocks action!)
	if paralyze_active_timer > 0.0 and paralyze_rect:
		paralyze_active_timer -= delta
		paralyze_frame_timer += delta
		var frame_dur = 0.075
		if paralyze_frame_timer >= frame_dur:
			paralyze_frame_timer -= frame_dur
			paralyze_frame_idx = (paralyze_frame_idx + 1) % PARALYZE_FRAMES.size()
			paralyze_rect.texture = PARALYZE_FRAMES[paralyze_frame_idx]
			# Electric shake / jitter around center (29, 56)
			paralyze_rect.position = Vector2(29.0 + randf_range(-2.0, 2.0), 56.0 + randf_range(-2.0, 2.0))

		# Fade out gently in the last 0.2s of the effect
		if paralyze_active_timer < 0.2:
			paralyze_rect.modulate.a = maxf(0.0, paralyze_active_timer / 0.2)
		else:
			paralyze_rect.modulate.a = 1.0

		if paralyze_active_timer <= 0.0:
			paralyze_rect.visible = false
			paralyze_rect.position = Vector2(29, 56)

	# 5. Sleep Animation (Zzz drifting upward and fading)
	if has_sleep and sleep_rect:
		sleep_cycle_time += delta
		var s_t = fmod(sleep_cycle_time * 0.7, 1.0)
		var s_idx = clampi(int(s_t * float(SLEEP_FRAMES.size())), 0, SLEEP_FRAMES.size() - 1)
		sleep_rect.texture = SLEEP_FRAMES[s_idx]
		sleep_rect.position = Vector2(75.0 + s_t * 18.0, 35.0 - s_t * 30.0)
		sleep_rect.modulate.a = sin(s_t * PI) * 0.95

	# 6. Confusion Animation (Golden Stars orbiting head)
	if has_confusion and confusion_rect:
		var orbit_x = 51.0 + sin(anim_time * 4.0) * 22.0
		var orbit_y = 6.0 + cos(anim_time * 4.0) * 5.0
		confusion_rect.position = Vector2(orbit_x, orbit_y)
		confusion_rect.rotation = sin(anim_time * 5.0) * 0.25
		confusion_rect.scale.x = 1.0 if cos(anim_time * 4.0) >= 0.0 else -1.0

	# 7. Trapped Animation (subtle spider web tremor)
	if has_trapped and trapped_rect:
		var web_alpha = 0.68 + 0.14 * sin(anim_time * 4.0)
		trapped_rect.modulate = Color(1.0, 1.0, 1.0, web_alpha)
