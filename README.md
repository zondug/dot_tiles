
# Isometric Grid with Pathfinding

This Godot script creates an isometric grid with adjustable angles and provides pathfinding functionality using the AStar2D algorithm.

## Features
<img width="440" alt="image" src="https://github.com/zondug/dot_tiles/assets/13306437/82b99b4c-8bbc-470b-9a93-46f23f2cab32"> <img width="440" alt="image" src="https://github.com/zondug/dot_tiles/assets/13306437/ca1d25e4-c49b-4ef6-9eda-4a812c1e65e6">


- Adjustable angles between (0, 0) and (0, 1), and between (0, 0) and (1, 0)
- Customizable grid size and cell dimensions
- Different dot sizes for grid points that are multiples of 4 and other grid points
- Clicking on a grid point selects it and highlights adjacent points within a specified distance
- Pathfinding from (0, 0) to the clicked point using the AStar2D algorithm
- Drawing the shortest path as a curved line using cosine interpolation
- Customizable adjacent point distance through user input

## Usage

1. Attach this script to a Node2D in your Godot project.
2. Adjust the following variables as needed:
   - `angle_h`: Desired angle (in degrees) between (0, 0) and (0, 1)
   - `angle_w`: Desired angle (in degrees) between (0, 0) and (1, 0)
   - `adj_distance`: Distance between adjacent points
   - `grid_size_x` and `grid_size_y`: Grid dimensions
   - `cell_width` and `cell_height`: Cell dimensions
   - `dot_size_multiple_of_4`: Dot size for grid points where both x and y are multiples of 4
   - `dot_size_others`: Dot size for other grid points
3. Run the project and interact with the grid:
   - Click on a grid point to select it and highlight adjacent points within the specified distance.
   - The shortest path from (0, 0) to the clicked point will be calculated and drawn as a curved line.
   - Enter the desired angles and adjacent distance in the corresponding LineEdit nodes to update the grid.

## Dependencies

- Godot Engine (version 4.0 or later)

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- The pathfinding functionality is implemented using the AStar2D algorithm provided by Godot Engine.
- The curved path drawing is achieved using cosine interpolation.

Feel free to customize and enhance this script according to your specific requirements.
