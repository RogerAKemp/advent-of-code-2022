defmodule Day09 do
  @input "input-09.txt"
  @vector %{"L"=>{0, -1}, "R"=>{0, 1}, "U"=>{1, 0}, "D"=>{-1, 0}}

  def part1() do
    process_input(2)
  end

  def part2() do
    process_input(10)
  end

  def process_input(rope_length) do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.map(&String.split(&1," ", trim: true))
    |> Enum.reduce({List.duplicate({0, 0}, rope_length), [{0, 0}]}, fn [dir, count], acc ->
          move_rope(acc, dir, String.to_integer(count)) end)
    |> elem(1)
    |> Enum.uniq
    |> Enum.count
  end

  def move_rope({rope, locations}, _dir, 0), do: {rope, locations}

  def move_rope({rope, locations}, dir, count) do
    rope
    |> move_rope_one_step([], dir)
    |> (&{&1, [List.last(&1) | locations]}).()
    |> move_rope(dir, count - 1)
  end

  # Reverse the final result
  def move_rope_one_step([], new_rope, _dir), do: Enum.reverse(new_rope)

  # Start new rope by moving head
  def move_rope_one_step([head | rest], [], dir) do
    move_rope_one_step(rest, [move_head(head, dir)], dir)
  end

  # Move remainder of rope based on new knot position of previous knot
  def move_rope_one_step([head | rest], new_rope, dir) do
    move_rope_one_step(rest, [move_knot(hd(new_rope), head, dir) | new_rope], dir)
  end

  def move_head({row, col}, dir), do: {row + elem(@vector[dir], 0), col + elem(@vector[dir], 1)}

  # Return new tail knot based on positions of new head and old tail knots
  def move_knot({h_row, h_col}, {t_row, t_col}, dir) do
    get_position(t_row, t_col, h_row - t_row, h_col - t_col, dir)
  end

  def sign(x) when x > 0, do: 1
  def sign(x) when x < 0, do: -1
  def sign(0), do: 0

  def get_position(t_row, t_col, dr, dc, dir) when dc == 2 or dc == -2 or dr == 2 or dr == -2 do
    {t_row + sign(dr), t_col + sign(dc)}
  end

  def get_position(t_row, t_col, _dr, _dc, _), do: {t_row, t_col}
end
