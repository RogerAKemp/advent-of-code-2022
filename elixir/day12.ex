defmodule Day12 do
  @dirs [[0, 1], [1, 0], [0, -1], [-1, 0]]

  @input "input-12.txt"

  # Get grid, flood it with increasing distances from start position in uphill direction
  # Return the number of steps to reach end position
  def part1() do
    {grid, nrows, ncols, start_position, end_position} = get_initial_grid()

    {grid, nrows, ncols, start_position}
    |> flood_grid(1)
    |> Map.get(end_position)
    |> elem(1)
  end

  # Get grid, flood it with increasing distances from end position in downhill direction
  # Return the distance to the location of an a? character that has the smallest value
  def part2() do
    {grid, nrows, ncols, _start_position, end_position} = get_initial_grid()

    flood_grid({grid, nrows, ncols, end_position}, -1)
    |> Map.values
    |> Enum.filter(fn {char, distance} -> char == ?a and distance != nil end)
    |> Enum.reduce(fn {_char, distance}, acc -> min(acc, distance) end)
  end

  # Read file and return tuple with grid initial configuration
  # {map of index => {height, distance=nil}, nrows, ncols, starting position, ending position}
  def get_initial_grid() do
    data = @input |> File.read! |> String.split("\n")
    nrows = length(data)

    data = data |> Enum.join |> String.to_charlist

    start_position = Enum.find_index(data, fn x -> x == ?S end)
    end_position = Enum.find_index(data, fn x -> x == ?E end)

    data
    |> List.replace_at(end_position, ?z)
    |> List.replace_at(start_position, ?a)
    |> Enum.with_index
    |> Enum.into(%{}, fn {char, index} -> {index, {char, nil}} end)
    |> (&{&1, nrows, div(length(data), nrows), start_position, end_position}).()
  end


  # Call routine to fill grid with distances from start_position
  def flood_grid({grid, nrows, ncols, start_position}, direction) do
    do_flood_grid(grid, nrows, ncols, [{start_position, 0}], MapSet.new(), direction)
  end

  # No more neighbors to flood. Return grid.
  def do_flood_grid(grid, _nrows, _ncols, [], _visited, _direction) do
    grid
  end

  # Set number of steps from start_position to each cell recursively
  # Get head of list of cells to fill, update it and add its neighbors to the end of the list to fill
  def do_flood_grid(grid, nrows, ncols, [head | tail], visited, direction) do
    position = elem(head, 0)
    distance = elem(head, 1)
    new_grid = Map.put(grid, position, {height(grid, position), distance})
    neighbors = get_valid_next_neigbors(new_grid, position, nrows, ncols, visited, direction)
    new_visited = MapSet.union(visited, new_edges(position, neighbors))
    do_flood_grid(new_grid, nrows, ncols,
          tail ++ Enum.map(neighbors, fn index -> {index, distance + 1} end), new_visited, direction)
  end

  # Return list of unvisited neighbor indexes of one step higher or lower than current position
  # Places to go next
  def get_valid_next_neigbors(grid, position, nrows, ncols, visited, direction) do
    get_neigbors(position, nrows, ncols)
    |> Enum.filter(fn index -> (height(grid, index) - height(grid, position))*direction <= 1 end)
    |> Enum.reject(fn index -> MapSet.member?(visited, edge(position, index)) end)
  end

  # Return list of valid neighbor indexes of current position
  def get_neigbors(position, nrows, ncols) do
    @dirs |> Enum.reduce([], &add_neighbor_index(position, &1, nrows, ncols, &2))
  end

  # Position this out of bounds. Return accumulator
  def add_neighbor_index(position, [dr, dc], nrows, ncols, acc)
      when (position < ncols and dr == -1) or (position >= (nrows - 1)*ncols and dr == 1) or
      (rem(position, ncols) == 0 and dc == -1) or (rem(position, ncols) == ncols - 1 and dc == 1), do: acc

  # Add this position to accumulator list of neighbors of the current cell
  def add_neighbor_index(position, [dr, dc], _nrows, ncols, acc), do: [position + ncols*dr + dc | acc]

  def height(grid, index), do: elem(Map.get(grid, index), 0)
  def distance(grid, index), do: elem(Map.get(grid, index), 1)

  # Generate a list of edges to neighbor cells which will be added to MapSet of visited edges that need not be considered again
  def new_edges(position, neighbors) do
    neighbors
    |> Enum.reduce(MapSet.new(), fn neighbor, acc -> MapSet.put(acc, edge(position, neighbor)) end)
  end

  # Create code name for edge with the lower index node first
  def edge(position, neighbor) when position<neighbor, do: Integer.to_string(position) <> "-" <> Integer.to_string(neighbor)
  def edge(position, neighbor), do: Integer.to_string(neighbor) <> "-" <> Integer.to_string(position)
end
