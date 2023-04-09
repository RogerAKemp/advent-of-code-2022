defmodule Day14 do

  defstruct [:xmin, :xmax, :ymax, :cells, count: 0, complete: false]
  @input "input-14.txt"

  def part1() do
    process_input()
    |> add_walls_to_grid()
    |> find_x_limits()
    |> find_y_limit()
    |> add_sand_to_grid()
    |> Map.get(:count)
  end

  def part2() do
    process_input()
    |> add_walls_to_grid()
    |> find_x_limits()
    |> find_y_limit()
    |> add_floor()
    |> add_sand_to_grid()
#    |> grid_to_string()
    |> Map.get(:count)
  end

  # Read text file and convert each row to a list of tuples [{x1, y1}, {x2, y2}...]
  def process_input() do
    @input
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ~r/\d+/, include_captures: true, trim: true))
    |> Enum.map(fn row -> Enum.filter(row, &Regex.match?(~r/\d+/, &1)) end)
    |> Enum.map(&Enum.chunk_every(&1, 2))
    |> Enum.map(&Enum.map(&1, fn [sx, sy] -> {String.to_integer(sx), String.to_integer(sy)} end))
  end

  # Fill grid map using the corner points of the walls
  def add_walls_to_grid(rows) do
    %Day14{cells: rows |> Enum.reduce(%{}, fn row, grid -> process_input_row(row, grid) end)}
  end

  # Assign cells of grid map for one wall definition
  def process_input_row(row, grid) do
    row
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(grid, fn [{x1, y1}, {x2, y2}], acc -> add_walls_to_grid({x1, y1}, {x2, y2}, acc) end)
  end

  # Add one wall segment to map
  def add_walls_to_grid({x1, y1}, {x2, y2}, grid) do
    points_in_between({x1, y1}, {x2, y2})
    |> Enum.reduce(grid, fn {x, y}, acc -> Map.put(acc, {x, y}, "#") end)
  end

  # Return points making up one vertical wall segment
  def points_in_between({x1, y1}, {x2, y2}) when x1 == x2 do
    y1..y2 |> Enum.map(&({x1, &1}))
  end

  # Return points making up one horizontal wall segment
  def points_in_between({x1, y1}, {x2, _y2}) do
    x1..x2 |> Enum.map(&({&1, y1}))
  end

  # Find and record the x limits of the grid
  def find_x_limits(%Day14{} = grid) do
    points = Map.keys(grid.cells) |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
    %Day14{grid | xmin: elem(hd(points), 0), xmax: elem(List.last(points), 0)}
  end

  # Find and record the x limit of the grid
  def find_y_limit(%Day14{} = grid) do
    points = Map.keys(grid.cells) |> Enum.sort(&(elem(&1, 1) < elem(&2, 1)))
    %Day14{grid | ymax: elem(List.last(points), 1)}
  end

  # No more sand can be added to grid.
  def add_sand_to_grid(%Day14{} = grid) when grid.complete, do: grid

  # Drop one grain into grid at starting location and track it
  def add_sand_to_grid(%Day14{} = grid) do
    move_sand_grain(grid, {500, 0})
    |> add_sand_to_grid
  end

  # Grain moved out of bounds or cannot enter grid at all.  Filling is complete
  def move_sand_grain(%Day14{} = grid, {x, y}) when x < grid.xmin or x > grid.xmax
       or y > grid.ymax or is_map_key(grid.cells, {500, 0}) do
        %Day14{grid | complete: true}
  end

  # Grain cannot move further. Record its location
  def move_sand_grain(%Day14{} = grid, {x, y}) when is_map_key(grid.cells, {x, y + 1}) and
  is_map_key(grid.cells, {x - 1, y + 1}) and is_map_key(grid.cells, {x + 1, y + 1}) do
    %Day14{grid | cells: Map.put(grid.cells, {x, y}, "O"), count: grid.count + 1}
  end

  # Grain must move right
  def move_sand_grain(%Day14{} = grid, {x, y}) when is_map_key(grid.cells, {x, y + 1}) and
  is_map_key(grid.cells, {x - 1, y + 1}) do
    move_sand_grain(grid, {x + 1, y + 1})
  end

  # Grain must move left
  def move_sand_grain(%Day14{} = grid, {x, y}) when is_map_key(grid.cells, {x, y + 1}) do
    move_sand_grain(grid, {x - 1, y + 1})
  end

  # Grain can fall down one position
  def move_sand_grain(%Day14{} = grid, {x, y}) do
    move_sand_grain(grid, {x, y + 1})
  end

  # Add floor two steps below the ymax row
  def add_floor(%Day14{} = grid) do
    (500 - grid.ymax - 2)..(500 + grid.ymax + 2)
    |> Enum.reduce(%Day14{grid | xmin: (500 - grid.ymax - 2), xmax: (500 + grid.ymax + 2), ymax: grid.ymax + 2},
          fn x, acc -> %Day14{acc | cells: Map.put(acc.cells, {x, grid.ymax + 2}, "#")} end)
  end

  # Convert grid to string for display
  def grid_to_string(grid) do
    for y <- 0..grid.ymax, x <- grid.xmin..grid.xmax, into: "" do
      case Map.has_key?(grid.cells, {x, y}) do
        true -> Map.get(grid.cells, {x, y})
        _ -> "."
      end
    end
    |> String.codepoints
    |> Enum.chunk_every(grid.xmax - grid.xmin + 1)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end
end
