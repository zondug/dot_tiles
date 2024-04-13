extends Node2D

var angle_h := 75.0 # Desired angle (in degrees) - Angle between (0, 0) and (0, 1)
var angle_w := -25.0 # Desired angle (in degrees) - Angle between (0, 0) and (1, 0)
var adj_distance := 3  # Set the distance between adjacent points

const grid_size_x = 13
const grid_size_y = 13
const cell_width = 50 # Cell size on the x-axis
const cell_height = 25 # Cell size on the y-axis
const dot_size_multiple_of_4 = 5 # Dot size for grid points where both x and y are multiples of 4
const dot_size_others = 1 # Dot size for other grid points
var selected_dot = null

@onready var line_edit = $CanvasLayer/CanvasGroup/LineEdit
@onready var line_edit_2 = $CanvasLayer/CanvasGroup/LineEdit2
@onready var line_edit_3 = $CanvasLayer/CanvasGroup/LineEdit3

var grid_width = grid_size_x * cell_width
var grid_height = grid_size_y * cell_height

var dot_positions = [] # Table to store the coordinates of each point
var route = []  # Array to store the path


func _ready():
	line_edit.text = str(angle_h) # Assign the text property to label
	line_edit_2.text = str(angle_w) 
	line_edit_3.text = str(adj_distance) 
	
	var viewport_size = get_viewport_rect().size
	var grid_origin = Vector2(viewport_size.x * 1/3, viewport_size.y * 1/3)
	position = grid_origin - Vector2((grid_size_x - 1) * cell_width * calculate_offsets(angle_w).x / 2 + (grid_size_y - 1) * cell_width * calculate_offsets(angle_h).x / 2,
									 (grid_size_x - 1) * cell_height * calculate_offsets(angle_w).y / 2 + (grid_size_y - 1) * cell_height * calculate_offsets(angle_h).y / 2)

func _draw():
	var h_offsets = calculate_offsets(angle_h)
	var w_offsets = calculate_offsets(angle_w)
	var x_offset_h = h_offsets.x
	var y_offset_h = h_offsets.y
	var x_offset_w = w_offsets.x
	var y_offset_w = w_offsets.y

	dot_positions.clear()

	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var x = position.x + i * cell_width * x_offset_w + j * x_offset_h * cell_width
			var y = position.y + i * cell_height * y_offset_w + j * cell_height * y_offset_h
			var dot_position = Vector2(x, y)
			var dot_size = dot_size_multiple_of_4 if i % 4 == 0 and j % 4 == 0 else dot_size_others

			draw_circle(dot_position, dot_size, Color.RED)
			dot_positions.append(Vector2(i, j))  # Store the coordinates (i, j) of the point in the array

	draw_selected_dot()  # Call the function to draw the selected point
	draw_adjacent_dots()  # Call the function to draw the adjacent points
	#draw_route()  # Call the function to draw the path


func draw_selected_dot(): # Call the function to draw the selected point
	if selected_dot != null:
		var selected_dot_index = int(selected_dot.y) * grid_size_x + int(selected_dot.x)
		var selected_dot_position = position + Vector2(selected_dot.x * cell_width * calculate_offsets(angle_w).x + selected_dot.y * cell_width * calculate_offsets(angle_h).x,
													   selected_dot.x * cell_height * calculate_offsets(angle_w).y + selected_dot.y * cell_height * calculate_offsets(angle_h).y)
		draw_circle(selected_dot_position, dot_size_multiple_of_4 if selected_dot_index % (grid_size_x * 4) == 0 else dot_size_others, Color.AZURE)

func draw_adjacent_dots(): # Call the function to draw the adjacent points
	if selected_dot != null:
		var adjacent_dots = get_adjacent_dots(selected_dot, adj_distance)
		
		for dot in adjacent_dots:
			var dot_index = int(dot.y) * grid_size_x + int(dot.x)
			var dot_position = position + Vector2(dot.x * cell_width * calculate_offsets(angle_w).x + dot.y * cell_width * calculate_offsets(angle_h).x,
												  dot.x * cell_height * calculate_offsets(angle_w).y + dot.y * cell_height * calculate_offsets(angle_h).y)
			var dot_size = dot_size_multiple_of_4 if dot_index % (grid_size_x * 4) == 0 else dot_size_others
			draw_circle(dot_position, dot_size, Color.AQUAMARINE)

func get_adjacent_dots(dot, distance):
	var adjacent_dots = []
	
	for offset_x in range(-distance, distance + 1):
		for offset_y in range(-distance, distance + 1):
			if offset_x == 0 and offset_y == 0:
				continue  # Exclude itself
			
			var adj_x = dot.x + offset_x
			var adj_y = dot.y + offset_y
			
			if adj_x >= 0 and adj_x < grid_size_x and adj_y >= 0 and adj_y < grid_size_y:
				if abs(offset_x) + abs(offset_y) <= distance:  # Calculate Manhattan distance and include only points within the distance
					adjacent_dots.append(Vector2(adj_x, adj_y))
	
	return adjacent_dots

func update_nearby_dots(distance):
	if selected_dot != null:
		var adjacent_dots = get_adjacent_dots(selected_dot, distance)
		print("Adjacent dots to the selected dot (distance: %d):" % distance, adjacent_dots)
		queue_redraw()  # Call queue_redraw to redraw the highlighted points
	else:
		queue_redraw()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_position = get_local_mouse_position()
		print_rich("[color=red]Clicked![/color]")
		
		var closest_dot = find_closest_dot(mouse_position)
		if closest_dot != null:
			selected_dot = closest_dot
			print("Clicked coordinates: ", selected_dot)
			
			update_nearby_dots(adj_distance)  # Call update_nearby_dots function passing adj_distance value
			find_path(Vector2(0, 0), selected_dot)  # Find the path from (0, 0) to the selected point
			queue_redraw()  # Call queue_redraw to redraw the highlighted point
		else:
			selected_dot = null
			route.clear()  # Clear the path
			queue_redraw()

func find_closest_dot(mouse_position):
	var min_distance = INF
	var closest_dot = null
	
	for i in range(dot_positions.size()):
		var dot_position = position + Vector2(dot_positions[i].x * cell_width * calculate_offsets(angle_w).x + dot_positions[i].y * cell_width * calculate_offsets(angle_h).x,
											  dot_positions[i].x * cell_height * calculate_offsets(angle_w).y + dot_positions[i].y * cell_height * calculate_offsets(angle_h).y)
		var distance = mouse_position.distance_to(dot_position)
		if distance < min_distance:
			min_distance = distance
			closest_dot = dot_positions[i]
	return closest_dot

func find_path(start, end):
	var astar = AStar2D.new()
	
	# Add all points to AStar2D
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var point = Vector2(i, j)
			var point_index = calculate_point_index(point)
			astar.add_point(point_index, point)
	
	# Add connections between adjacent points
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var point = Vector2(i, j)
			var point_index = calculate_point_index(point)
			var points_relative = PackedVector2Array([
				Vector2(point.x + 1, point.y),
				Vector2(point.x - 1, point.y),
				Vector2(point.x, point.y + 1),
				Vector2(point.x, point.y - 1)
			])
			for point_relative in points_relative:
				var point_relative_index = calculate_point_index(point_relative)
				if is_outside_map(point_relative):
					continue
				if not astar.has_point(point_relative_index):
					continue
				astar.connect_points(point_index, point_relative_index, false)
	
	var start_index = calculate_point_index(start)
	var end_index = calculate_point_index(end)
	route = astar.get_point_path(start_index, end_index)
	print("Shortest path from (0, 0) to the clicked point:", route)

func is_outside_map(point):
	return point.x < 0 or point.y < 0 or point.x >= grid_size_x or point.y >= grid_size_y

func calculate_point_index(point):
	return point.x + grid_size_x * point.y

func draw_route():
	if route.size() > 1:
		# Set the number of interpolation points
		var num_points = 100
		
		# Initialize the array of interpolated points
		var interpolated_points = []
		
		# Calculate the total distance of the path
		var total_distance = 0
		for i in range(route.size() - 1):
			var start_point = route[i]
			var end_point = route[i + 1]
			var distance = start_point.distance_to(end_point)
			total_distance += distance
		
		# Interpolate the points along the path to draw a curve
		var current_distance = 0
		for i in range(route.size() - 1):
			var start_point = route[i]
			var end_point = route[i + 1]
			var distance = start_point.distance_to(end_point)
			
			var start_position = position + Vector2(start_point.x * cell_width * calculate_offsets(angle_w).x + start_point.y * cell_width * calculate_offsets(angle_h).x,
													start_point.x * cell_height * calculate_offsets(angle_w).y + start_point.y * cell_height * calculate_offsets(angle_h).y)
			var end_position = position + Vector2(end_point.x * cell_width * calculate_offsets(angle_w).x + end_point.y * cell_width * calculate_offsets(angle_h).x,
												  end_point.x * cell_height * calculate_offsets(angle_w).y + end_point.y * cell_height * calculate_offsets(angle_h).y)
			
			# Calculate points using cosine interpolation
			for j in range(num_points + 1):
				var t = float(j) / num_points
				var d = current_distance + t * distance
				var ratio = d / total_distance
				var x = cosine_interpolate(start_position.x, end_position.x, ratio)
				var y = cosine_interpolate(start_position.y, end_position.y, ratio)
				interpolated_points.append(Vector2(x, y))
			
			current_distance += distance
		
		# Draw the curve using the interpolated points
		for i in range(interpolated_points.size() - 1):
			draw_line(interpolated_points[i], interpolated_points[i + 1], Color.YELLOW, 2)

# Cosine interpolation function
func cosine_interpolate(start, end, t):
	var cos_t = (1 - cos(t * PI)) / 2
	return start * (1 - cos_t) + end * cos_t

func draw_custom_line(start_x, end_x, start_y, end_y, color, width):
	var start_index = start_y * grid_size_y + start_x
	var end_index = end_y * grid_size_y + end_x
	draw_line(dot_positions[start_index], dot_positions[end_index], color, width)

func calculate_offsets(angle_degrees):
	var angle_radians = deg_to_rad(angle_degrees)
	var x_offset = cos(angle_radians)
	var y_offset = sin(angle_radians)
	return Vector2(x_offset, y_offset)

func _on_line_edit_text_submitted(new_text):
	angle_h = float(new_text)
	print("Entered (0, 0) and (0, 1) Angle: ", angle_h)
	queue_redraw()

func _on_line_edit_2_text_submitted(new_text):
	angle_w = float(new_text)
	print("Entered (0, 0) and (1, 0) Angle: ", angle_w)
	queue_redraw()

func _on_line_edit_3_text_submitted(new_text):
	adj_distance = float(new_text)
	print("Entered distance: ", adj_distance)
	queue_redraw()
