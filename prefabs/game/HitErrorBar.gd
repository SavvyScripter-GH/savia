extends Control

var visual_half_width: float = 300.0
var max_hit_window_ms: float = Rhythia.hitwindow_ms

var window_perfect: float = 30.0
var window_great: float = 70.0
var window_good: float = 120.0

func _ready():
	#_create_section(
	#	0,
	#	visual_half_width * 0.33,
	#	Color(0.2, 0.6, 1.0, 0.8) # blue
	#)

	#_create_section(
	#	visual_half_width * 0.33,
	#	visual_half_width * 0.66,
	#	Color(0.2, 0.8, 0.2, 0.8) # green
	#)

	#_create_section(
	#	visual_half_width * 0.66,
	#	visual_half_width,
	#	Color(0.8, 0.6, 0.1, 0.8) # orange
	#)

	#var bg = ColorRect.new()
	#bg.rect_size = Vector2(visual_half_width, 10)
	#bg.rect_position = Vector2(0, -5)
	#bg.color = Color(0.1, 0.1, 0.1, 0.4)
	#add_child(bg)
	pass

func _create_section(start_x: float, end_x: float, color: Color):
	var rect = ColorRect.new()

	rect.rect_size = Vector2(end_x - start_x, 20)
	rect.rect_position = Vector2(start_x, -10)

	rect.color = color

	add_child(rect)

func add_hit_tick(offset_ms: float):
	var percent = clamp(offset_ms / max_hit_window_ms, 0.0, 1.0)
	var x_pos = visual_half_width * percent
	
	var tick = ColorRect.new()
	tick.rect_size = Vector2(4, 20)
	tick.rect_position = Vector2(x_pos - 2, 10)
	
	var abs_offset = abs(offset_ms)
	if abs_offset <= window_perfect:
		tick.color = Color(0.5, 0.8, 1.0) 
	elif abs_offset <= window_great:
		tick.color = Color(0.5, 1.0, 0.5) 
	elif abs_offset <= window_good:
		tick.color = Color(1.0, 0.8, 0.4) 
	else:
		tick.color = Color(1.0, 0.4, 0.4)
	#tick.color = Color.cyan if offset_ms < 0 else Color.gold
	
	add_child(tick)
	
	var t = Tween.new()
	add_child(t)
	t.interpolate_property(tick, "modulate:a", 1.0, 0.0, 1.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	t.interpolate_property(tick, "rect_position:y", tick.rect_position.y, tick.rect_position.y + 15, 1.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	t.connect("tween_all_completed", tick, "queue_free")
	t.connect("tween_all_completed", t, "queue_free")
	t.start()
