defmodule Day13 do

  @input "input-13.txt"

  def part1() do
    @input
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(2)
    |> Enum.with_index
    |> Enum.reduce(0, fn {[left, right], index0}, acc -> acc + valid_score(left, right, index0) end)
  end

  def part2() do
    sorted = @input
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.concat(["[[2]]", "[[6]]"])
    |> Enum.sort(&(in_order?(elem(Code.string_to_quoted(&1), 1), elem(Code.string_to_quoted(&2), 1))))

    (Enum.find_index(sorted, &(&1 == "[[2]]")) + 1) * (Enum.find_index(sorted, &(&1 == "[[6]]")) + 1)
  end

  # Convert pairs of strings to list, compare and return index if valid or 0 otherwise
  def valid_score(left, right, index0) do
    if in_order?(elem(Code.string_to_quoted(left), 1), elem(Code.string_to_quoted(right), 1)),
    do: index0 + 1,
    else: 0
  end

  def in_order?(left, right) when is_integer(left) and is_integer(right) and left < right, do: true
  def in_order?(left, right) when is_integer(left) and is_integer(right) and left > right, do: false
  def in_order?(left, right) when is_integer(left) and is_integer(right) and left == right, do: :equal

  def in_order?([], []), do: :equal
  def in_order?([], _), do: true
  def in_order?(_, []), do: false

  def in_order?(left, right) when is_integer(left), do: in_order?([left], right)
  def in_order?(left, right) when is_integer(right), do: in_order?(left, [right])

  def in_order?([lh | lt], [rh | rt]) do
    case in_order?(lh, rh) do
      true -> true
      false -> false
      :equal -> in_order?(lt, rt)
    end
  end
end
