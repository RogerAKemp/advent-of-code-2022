defmodule Day05 do
  @input "input-05-moves.txt"
  @stacks %{1 => ["D","Z","T","H"], 2 => ["S","C","G","T","W","R","Q"],
      3 => ["H","C","R","N","Q","F","B","P"], 4 => ["Z","H","F","N","C","L"],
      5 => ["S","Q","F","L","G"], 6 => ["S","C","R","B","Z","W","P","V"],
      7 => ["J","F","Z"], 8 => ["Q","H","R","Z","V","L","D"],
      9 => ["D","L","Z","F","N","G","H","B"]}

  def part1(), do: process_input(&add_to_stack_1/2)

  def part2(), do: process_input(&add_to_stack_2/2)

  def process_input(add_function) do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.map(fn s -> String.split(s) end)
    |> Enum.map(fn list -> {String.to_integer(Enum.at(list, 1)),
        String.to_integer(Enum.at(list, 3)), String.to_integer(Enum.at(list, 5))} end)
    |> Enum.reduce(@stacks, fn tuple, new_stack ->
        remove_from_stack(add_function.(new_stack, tuple), tuple) end)
    |> Enum.to_list
    |> Enum.sort(fn ({key1, value1}, {key2, value2}) -> key1 < key2 end)
    |> Enum.reduce("", fn tuple, acc -> acc <>
      cond do
        elem(tuple, 1)==[] -> "-"
        true -> hd(elem(tuple, 1))
      end
    end)
  end

  def remove_from_stack(stack, {amount, from, _}) do
    from_crates = Map.get(stack, from)
    Map.put(stack, from, Enum.take(from_crates, amount - length(from_crates)))
  end

  def add_to_stack_1(stack, {amount, from, to}) do
    transfer_crates = Map.get(stack, from) |> Enum.take(amount) |> Enum.reverse
    Map.put(stack, to, transfer_crates ++ Map.get(stack, to))
  end

  def add_to_stack_2(stack, {amount, from, to}) do
    transfer_crates = Map.get(stack, from) |> Enum.take(amount)
    Map.put(stack, to, transfer_crates ++ Map.get(stack, to))
  end
end
