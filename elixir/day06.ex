defmodule Day06 do
  @input "input-06.txt"

  def part1(), do: process(4)

  def part2(), do: process(14)

  def process(size) do
    @input
    |> File.read!
    |> String.codepoints()
    |> Enum.chunk_every(size ,1)
    |> Enum.find_index(&Enum.uniq(&1) == &1)
    |> Kernel.+(size)
  end
end
