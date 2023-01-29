defmodule Day08 do
  @input "input-08.txt"

  def part1() do
    string_data = @input |> File.read! |> String.split("\n")
    width = String.length(hd(string_data))

    grid = string_data
    |> Enum.join
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)

    east = get_visibility(grid, width)

    west = grid
    |> reverse(width)
    |> get_visibility(width)
    |> reverse(width)

    north = grid
    |> transpose(width)
    |> get_visibility(width)
    |> transpose(width)

    south = grid
    |> transpose(width)
    |> reverse(width)
    |> get_visibility(width)
    |> reverse(width)
    |> transpose(width)

    east
    |> Enum.zip(west)
    |> Enum.map(fn {value1, value2} -> value1 or value2 end)
    |> Enum.zip(north)
    |> Enum.map(fn {value1, value2} -> value1 or value2 end)
    |> Enum.zip(south)
    |> Enum.map(fn {value1, value2} -> value1 or value2 end)
    |> Enum.count(fn value -> value end)
  end

  def reverse(grid, width) do
    grid
    |> Enum.chunk_every(width)
    |> Enum.map(&Enum.reverse/1)
    |> List.flatten
  end

  def transpose(grid, width) do
    0..length(grid)-1
    |> Enum.map(fn index -> Enum.at(grid, width*rem(index, width) + div(index, width)) end)
  end

  def get_visibility(grid, extent) do
    grid
    |> Enum.with_index
    |> Enum.map_reduce(-1, fn {value, index}, acc ->
        {visible?(value, index, acc), set_accumulator(index, extent, value, acc)} end)
    |> elem(0)
  end

  # Reset when at end of row or column
  def set_accumulator(index, extent, _value, _acc) when rem(index, extent) == extent - 1, do: -1
  def set_accumulator(_index, _extent, value, acc), do: max(value, acc)

  def visible?(_value, 0, _acc), do: true
  def visible?(value, _, acc) when value > acc, do: true
  def visible?(_value, _, _acc), do: false


  def part2() do
    {forest, height, width} = get_forest(@input)

    Enum.reduce(0..height-1, 0, fn r, row_max ->
      Enum.reduce(0..width-1, row_max, fn c, current_max ->
        acc = get_max_score(forest, r, c, height, width, current_max) end) end)
  end

  def get_forest(input_file) do
    forest = input_file
    |> File.read!
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)

    {forest, length(hd(forest)), length(forest)}
  end

  def get_max_score(forest, r, c, height, width, current_max) do
    max(count_trees(forest, r, c, height, width, -1, 0) *
    count_trees(forest, r, c, height, width, 0, 1) *
    count_trees(forest, r, c, height, width, 1, 0) *
    count_trees(forest, r, c, height, width, 0, -1), current_max)
  end

  def count_trees(forest, r, c, height, width, dr, dc) do
    count_trees(forest, Enum.at(Enum.at(forest, r), c), r, c, height, width, dr, dc)
  end

  def count_trees(forest, _this_tree, r, c, height, width, dr, dc) when r == 0 and dr == -1, do: 0
  def count_trees(forest, _this_tree, r, c, height, width, dr, dc) when r == height-1 and dr == 1, do: 0
  def count_trees(forest, _this_tree, r, c, height, width, dr, dc) when c == 0 and dc == -1, do: 0
  def count_trees(forest, _this_tree, r, c, height, width, dr, dc) when c == width-1 and dc == 1, do: 0

  def count_trees(forest, this_tree, r, c, height, width, dr, dc) do
    if this_tree > Enum.at(Enum.at(forest, r + dr), c + dc) do
      1 + count_trees(forest, this_tree, r + dr, c + dc, height, width, dr, dc)
    else
      1
    end
  end
end
