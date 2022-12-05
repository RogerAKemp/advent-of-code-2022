defmodule Day02 do
  @input "input-02.txt"
  @shape_score %{"X" => 1, "Y" => 2, "Z" => 3}
  @outcome_score %{"A Y" => 6, "B Z" => 6, "C X" => 6,
    "A X" => 3, "B Y" => 3, "C Z" => 3, "A Z" => 0, "B X" => 0, "C Y" => 0}
  @required_choice %{"A X" => "Z", "A Y" => "X", "A Z" => "Y",
    "B X" => "X", "B Y" => "Y", "B Z" => "Z", "C X" => "Y", "C Y" => "Z", "C Z" => "X"}

  def part1() do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.reduce(0, fn s, acc -> acc + Map.get(@shape_score, String.at(s, 2)) +
        Map.get(@outcome_score, s) end)
  end

  def part2() do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.map(fn s -> String.first(s) <> " " <> Map.get(@required_choice, s) end)
    |> Enum.reduce(0, fn s, acc -> acc + Map.get(@shape_score, String.at(s, 2)) +
        Map.get(@outcome_score, s) end)
  end
end
