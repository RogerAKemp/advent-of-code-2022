defmodule Day04 do
  @input "input-04.txt"

  def process_input() do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn list -> Enum.map(list, &String.split(&1, "-")) end)
    |> Enum.map(fn pair -> Enum.map(pair, fn sections ->
        Enum.map(sections, &String.to_integer/1) end) end)
  end

  def part1() do
    process_input
    |> Enum.reduce(0, fn pair, acc -> acc + contained?(pair) end)
  end

  def contained?([[id00, id01], [id10, id11]])
    when (id00 >= id10 and id01 <= id11) or (id10 >= id00 and id11 <= id01), do: 1
  def contained?(_), do: 0

  def part2() do
    process_input
    |> Enum.reduce(0, fn pair, acc -> acc + overlap?(pair) end)
  end

  def overlap?([[id00, id01], [id10, id11]])
    when (id01 >= id10 and id00 <= id10) or (id11 >= id00 and id10 <= id00), do: 1
  def overlap?(_), do: 0
end
