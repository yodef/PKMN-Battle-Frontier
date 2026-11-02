class_name CampaignTrackDiagram
extends Control

var total_stages: int = 9
var current_stage: int = 1
var is_completed: bool = false
var is_adventure_mode: bool = false

var pawn_rect: TextureRect = null
var pawn_tween: Tween = null
var node_positions: Array[Vector2] = []

func _init() -> void:
	custom_minimum_size = Vector2(0, 56)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_pawn()

func _setup_pawn() -> void:
	if pawn_rect != null:
		return
	pawn_rect = TextureRect.new()
	pawn_rect.name = "PawnMarker"
	pawn_rect.texture = load("res://assets/ui/pawn_marker.png")
	pawn_rect.custom_minimum_size = Vector2(20, 26)
	pawn_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pawn_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pawn_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pawn_rect)
	pawn_rect.visible = false

func set_campaign_progress(total: int, current: int, completed: bool = false, is_adventure: bool = false) -> void:
	total_stages = max(2, total)
	current_stage = current
	is_completed = completed
	is_adventure_mode = is_adventure
	queue_redraw()
	_update_pawn_position()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
		_update_pawn_position()

func _calculate_node_positions() -> void:
	node_positions.clear()
	var w = size.x
	if w <= 10.0:
		w = 460.0 # fallback before first layout pass
	var margin_x = 24.0
	var avail_w = w - (margin_x * 2.0)
	var step_x = avail_w / float(total_stages - 1)
	var center_y = 32.0
	
	for i in range(total_stages):
		var px = margin_x + (float(i) * step_x)
		node_positions.append(Vector2(px, center_y))

func _update_pawn_position() -> void:
	_calculate_node_positions()
	if not pawn_rect or node_positions.is_empty():
		return
		
	var target_stage_idx: int = 0
	if is_completed:
		target_stage_idx = total_stages - 1
	else:
		target_stage_idx = clampi(current_stage - 1, 0, total_stages - 1)
		
	var target_pos = node_positions[target_stage_idx]
	var base_x = target_pos.x - 10.0
	var base_y = target_pos.y - 25.0
	
	pawn_rect.visible = true
	pawn_rect.position = Vector2(base_x, base_y)
	
	# Smooth floating bobbing animation
	if pawn_tween and pawn_tween.is_valid():
		pawn_tween.kill()
		
	pawn_tween = create_tween().set_loops()
	pawn_tween.tween_property(pawn_rect, "position:y", base_y - 4.0, 0.60).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pawn_tween.tween_property(pawn_rect, "position:y", base_y, 0.60).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _draw() -> void:
	_calculate_node_positions()
	if node_positions.size() < 2:
		return
		
	var center_y = node_positions[0].y
	var p_start = node_positions[0]
	var p_end = node_positions[node_positions.size() - 1]
	
	# 1. Background full track line (inactive)
	draw_line(p_start, p_end, Color(0.10, 0.16, 0.24, 0.95), 6.0, true)
	draw_line(p_start, p_end, Color(0.18, 0.28, 0.38, 0.85), 3.0, true)
	
	# 2. Completed / Active track line
	var active_idx = total_stages - 1 if is_completed else clampi(current_stage - 1, 0, total_stages - 1)
	if active_idx > 0:
		var p_active = node_positions[active_idx]
		# Outer glow
		draw_line(p_start, p_active, Color(0.20, 0.75, 0.50, 0.35), 8.0, true)
		# Core progress line
		draw_line(p_start, p_active, Color(0.30, 0.88, 0.62, 1.0), 3.5, true)
		
	# 3. Draw Nodes
	var font = ThemeDB.fallback_font
	var font_size = 9
	
	for i in range(total_stages):
		var pos = node_positions[i]
		var stage_num = i + 1
		var is_boss_node = (i == total_stages - 1)
		
		if (i < current_stage - 1) or is_completed:
			# --- CLEARED STAGE ---
			draw_circle(pos, 8.5, Color(0.08, 0.14, 0.20, 1.0))
			draw_circle(pos, 7.0, Color(0.16, 0.58, 0.38, 1.0))
			draw_circle(pos, 3.5, Color(0.55, 1.0, 0.70, 1.0))
			draw_arc(pos, 8.5, 0, TAU, 24, Color(0.30, 0.85, 0.55, 1.0), 1.5, true)
			
			# Number / Status below
			var num_str = "✓" if not is_boss_node else ("👑" if is_adventure_mode else "🏆")
			var str_w = font.get_string_size(num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
			draw_string(font, Vector2(pos.x - (str_w / 2.0), pos.y + 18.0), num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.35, 0.88, 0.58))
			
		elif i == current_stage - 1 and not is_completed:
			# --- CURRENT ACTIVE STAGE (Pawn stands here) ---
			# Pulsing glow halo
			draw_circle(pos, 13.0, Color(1.0, 0.85, 0.25, 0.25))
			draw_circle(pos, 9.5, Color(0.15, 0.18, 0.24, 1.0))
			draw_circle(pos, 8.0, Color(0.95, 0.72, 0.18, 1.0))
			draw_circle(pos, 4.0, Color(1.0, 0.98, 0.70, 1.0))
			draw_arc(pos, 9.5, 0, TAU, 24, Color(1.0, 0.90, 0.40, 1.0), 2.0, true)
			
			# Active Stage Number
			var num_str = str(stage_num) if not is_boss_node else ("👑" if is_adventure_mode else "🏆")
			var str_w = font.get_string_size(num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
			draw_string(font, Vector2(pos.x - (str_w / 2.0), pos.y + 19.0), num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size + 1, Color(1.0, 0.92, 0.45))
			
		else:
			# --- FUTURE STAGE ---
			if is_boss_node:
				# Boss node highlight
				draw_circle(pos, 8.5, Color(0.10, 0.14, 0.20, 1.0))
				draw_arc(pos, 8.5, 0, TAU, 24, Color(0.85, 0.65, 0.25, 0.8), 1.5, true)
				var num_str = "👑" if is_adventure_mode else "🏆"
				var str_w = font.get_string_size(num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
				draw_string(font, Vector2(pos.x - (str_w / 2.0), pos.y + 18.0), num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.85, 0.70, 0.30))
			else:
				draw_circle(pos, 6.5, Color(0.08, 0.12, 0.18, 1.0))
				draw_circle(pos, 4.0, Color(0.15, 0.22, 0.30, 1.0))
				draw_arc(pos, 6.5, 0, TAU, 24, Color(0.24, 0.36, 0.48, 0.8), 1.2, true)
				
				var num_str = str(stage_num)
				var str_w = font.get_string_size(num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
				draw_string(font, Vector2(pos.x - (str_w / 2.0), pos.y + 18.0), num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.40, 0.52, 0.65))
