defmodule Monkey do
  defstruct [:items, :operation, :divisor, :if_true, :if_false]

  @input "input-11.txt"

  def part1(count) do
    prepare_monkeys()
    |> Tuple.append(fn(worry) -> div(worry, 3) end)
    |> do_round(count)
    |> Enum.sort(:desc)
    |> (&(hd(&1) * hd(tl(&1)))).()
  end

  def part2(count) do
    prepare_monkeys()
    |> (&Tuple.append(&1, fn(worry) -> worry |> rem(elem(&1, 0).lcm) end)).()
    |> do_round(count)
    |> Enum.sort(:desc)
    |> (&(hd(&1) * hd(tl(&1)))).()
  end

  # Return totals after rounds are completed
  def do_round({_monkeys, totals, _worry_fn}, 0), do: totals

  # Perform one round of monkeys and then attempt the next
  def do_round({monkeys, totals, worry_fn}, count) do
    do_monkey({monkeys, totals, worry_fn}, 0)
    |> do_round(count - 1)
  end

  # Current round is complete
  def do_monkey({monkeys, totals, worry_fn}, number) when number == length(totals), do: {monkeys, totals, worry_fn}

   # Peform monkey #number's turn then attempt do the next.
   def do_monkey({monkeys, totals, worry_fn}, number) do
    monkey = monkeys[number]
    monkey.items
    |> Enum.reduce(monkeys, fn item, acc ->
        result = test_item(item, monkey, worry_fn)

        acc
        |> update_thrower(number)
        |> update_recipient(result)
       end)
    |> (&{&1, List.replace_at(totals, number, Enum.at(totals, number) + length(monkey.items)), worry_fn}).()
    |> do_monkey(number + 1)
  end

  # Perform test and return a tuple of new item value and # of recipient monkey
  def test_item(item, monkey, worry_fn) do
    item
    |> do_operation(monkey.operation, worry_fn)
    |> get_recipient(monkey.divisor, monkey.if_true, monkey.if_false)
  end

  def get_recipient(item, divisor, if_true, _) when rem(item, divisor) == 0, do: {item, if_true}
  def get_recipient(item, _divisor, _, if_false), do: {item, if_false}

  # Add new_item to end of recipient's list
  def update_recipient(monkeys, {new_item, recipient}) do
    Map.put(monkeys, recipient, %{monkeys[recipient] | items: monkeys[recipient].items ++ [new_item]})
  end

  # Remove item from thrower's list
  def update_thrower(monkeys, thrower) do
    Map.put(monkeys, thrower, %{monkeys[thrower] | items: tl(monkeys[thrower].items)})
  end

  # Perform this monkey's operation and apply the worry function to the result.
  def do_operation(item, {x1, op, x2}, worry_fn) do
    apply_operator(op, get_value(item, x1), get_value(item, x2))
    |> worry_fn.()
  end

  def get_value(item, x) when x == "old", do: item
  def get_value(_item, x), do: String.to_integer(x)

  def apply_operator("*", a, b), do: a * b
  def apply_operator("/", a, b), do: div(a, b)
  def apply_operator("+", a, b), do: a + b
  def apply_operator("-", a, b), do: a - b

  # Read input, preare a map of # => %Monkey plus the common multiplier (not necessarily LCM)
  # Wrap Map in a tuple with initial totals list [0, 0, ...]
  def prepare_monkeys() do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.chunk_every(7)
    |> Enum.reduce(%{:lcm => 1}, fn lines, acc -> add_monkey(lines, acc) end)
    |> (&{&1, List.duplicate(0, length(Map.to_list(&1)) - 1)}).()
  end

  # Parse 6 lines containing the definition for a monkey and update the common multiplier used in Part 2
  def add_monkey(lines, monkeys) do
    number = get_num(hd(lines))

    Map.put(monkeys, number, %Monkey{
        items: get_num_list(Enum.at(lines, 1)),
        operation: get_operation(Enum.at(lines, 2)),
        divisor: get_num(Enum.at(lines, 3)),
        if_true: get_num(Enum.at(lines, 4)),
        if_false: get_num(Enum.at(lines, 5))})
    |> (&Map.put(&1, :lcm, monkeys.lcm * &1[number].divisor)).()
  end

  # Pull integer from line of input
  def get_num(line) do
    line
    |> (&Regex.run(~r/\d+/, &1)).()
    |> hd
    |> String.to_integer
  end

  # Pull list of integers from line of input
  def get_num_list(line) do
    line
    |> (&Regex.scan(~r/\d+/, &1)).()
    |> List.flatten
    |> Enum.map(&String.to_integer/1)
  end

  # Parse operation from line of input into a tuple {x1, op, x2}
  def get_operation(line) do
    line
    |> (&Regex.named_captures(~r/=\s(?<x1>\w+)\s(?<op>\W)\s(?<x2>\w+)/, &1)).()
    |> (&{&1["x1"], &1["op"], &1["x2"]}).()
  end
end
