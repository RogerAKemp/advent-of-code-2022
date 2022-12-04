defmodule Day01 do
  @input "input-01.txt"

  def get_sums() do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.chunk_by(&(&1==""))
    |> Enum.reject(&(&1==[""]))
    |> Enum.map(fn list ->
      Enum.reduce(list, 0, fn s, acc -> acc + String.to_integer(s) end) end)
  end

  def part1() do
    Enum.max(get_sums())
  end

  def part2() do
    get_sums()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum
  end
end
