defmodule Day03 do
  @input "input-03.txt"

  def part1() do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.reduce(0, fn s, acc -> acc + priority(get_repeated_letter(s)) end)
  end

  def get_repeated_letter(s) do
    {first, second} = String.split_at(s, div(byte_size(s), 2))
    second
    |> String.codepoints
    |> Enum.filter(fn s -> String.contains?(first, s) end)
    |> hd
    |> String.to_charlist
    |> hd
  end

  def part2() do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.chunk_every(3)
    |> Enum.map(fn list -> Enum.map(list, &String.codepoints/1) end)
    |> Enum.reduce([], fn list, acc -> acc ++
        MapSet.to_list(MapSet.intersection(MapSet.new(Enum.at(list, 2)),
        MapSet.intersection(MapSet.new(Enum.at(list, 0)), MapSet.new(Enum.at(list, 1))))) end)
    |> Enum.reduce(0, fn s, acc -> acc + priority(hd(String.to_charlist(s))) end)
  end

  def priority(letter) when letter in ?A..?Z, do: letter - 38
  def priority(letter), do: letter-96
end
