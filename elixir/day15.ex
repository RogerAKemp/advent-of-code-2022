defmodule Day15 do

  @input "input-15.txt"

  def part1(row \\ 2000000) do
    sensor_data = process_input()

    sensor_data
    |> get_coverage(row)
    |> remove_known_beacons(sensor_data, row)
    |> IO.inspect(label: "Covered cells")
    |> Enum.reduce(0, fn {x1, x2}, acc -> acc + x2 - x1 + 1 end)
  end

  def part2(xmax \\ 4000000) do
    process_input()
    |> find_uncovered_cell(0, xmax, [{0, xmax}])
    |> IO.inspect(label: "Uncovered cell")
    |> (&(elem(&1, 0)*4000000 + elem(&1, 1))).()
  end

  # Set with uncovered cell will have either multiple coverage segments, or missing coverage at 0 or xmax
  def find_uncovered_cell(_, row, _xmax, [{_, x2}, {_, _}]), do: {x2 + 1, row - 1}
  def find_uncovered_cell(_, row, xmax, [{1, xmax}]), do: {0, row - 1}
  def find_uncovered_cell(_, row, xmax, [{0, x}]) when x == xmax - 1, do: {xmax, row - 1}

  # Iterate through each row looking for instance of an uncovered cell
  def find_uncovered_cell(sensor_data, row, xmax, [{_, _}]) do
    find_uncovered_cell(sensor_data, row + 1, xmax, get_coverage(sensor_data, row))
  end

  # Read text file and convert each row to a list of tuples [{x1, y1}, {x2, y2}]
  def process_input() do
    @input
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ~r/-?\d+/, include_captures: true, trim: true))
    |> Enum.map(fn row -> Enum.filter(row, &Regex.match?(~r/-?\d+/, &1)) end)
    |> Enum.map(&Enum.chunk_every(&1, 2))
    |> Enum.map(&Enum.map(&1, fn [sx, sy] -> {String.to_integer(sx), String.to_integer(sy)} end))
  end

  # Ignore empty segment tuple
  def insert_segment(set, {}), do: set

  # Insert into empty set list
  def insert_segment([], {x1, x2}), do: [{x1, x2}]

  # Insert before current segment
  def insert_segment([{w1, w2} | tail], {x1, x2}) when x2 < w1 - 1 do
    [{x1, x2}, {w1, w2} | tail]
  end

  # Insert after current segment
  def insert_segment([{w1, w2} | tail], {x1, x2}) when x1 > w2 + 1 do
    [{w1, w2} | insert_segment(tail, {x1, x2})]
  end

  # New segment overlaps current one.  Merge them and see if next segment also affected.
  def insert_segment([{w1, w2} | tail], {x1, x2}) do
    insert_segment(tail, {min(w1, x1), max(w2, x2)})
  end

  # Row is out of range. Return empty tuple
  def get_coverage([{sx, sy}, {bx, by}], row)
        when Kernel.abs(sx - bx) + Kernel.abs(sy - by) < Kernel.abs(sy - row), do: {}

  # Return tuple of the {xmin, xmax} range covered by this sensor for this row
  def get_coverage([{sx, sy}, {bx, by}], row) do
    distance = Kernel.abs(sx - bx) + Kernel.abs(sy - by)
    {sx - distance + Kernel.abs(sy - row), sx + distance - Kernel.abs(sy - row)}
  end

  # Get set of segments of all cells covered by the sensors
  def get_coverage(sensor_data, row) do
    sensor_data
    |> Enum.reduce([], fn sensor_beacon, acc -> insert_segment(acc, get_coverage(sensor_beacon, row)) end)
  end

  # Remove all beacons from coverage set of current row
  def remove_known_beacons(set, sensor_data, row) do
    sensor_data
    |> Enum.reduce(set, fn [_, {bx, by}], acc -> update_set(acc, bx, by, row) end)
  end

  # Beacon in current row.  Check segments
  def update_set(set, bx, row, row) do
    set
    |> Enum.reduce([], fn {w1, w2}, acc -> update_segment(w1, w2, bx) ++ acc end)
    |> Enum.reverse
  end

  # Beacon not in current row. No update needed
  def update_set(set, _bx, _by, _row), do: set

  # Beacon not in current segment. No update needed
  def update_segment(w1, w2, bx) when bx < w1 or bx > w2, do: [{w1, w2}]

  # Remove beacon from start of segment
  def update_segment(w1, w2, bx) when bx == w1,  do: [{w1 + 1, w2}]

  # Remove beacon from end of segment
  def update_segment(w1, w2, bx) when bx == w2,  do: [{w1, w2 - 1}]

  # Remove beacon from middle of segment
  def update_segment(w1, w2, bx),  do: [{bx + 1, w2}, {w1, bx - 1}]
end
