defmodule Day10 do
  @input "input-10.txt"

  def part1(), do: process_input() |> elem(3)
  def part2(), do: process_input() |> elem(4) |> String.split("\n", trim: true)

  def process_input() do
    @input
    |> File.read!
    |> String.split("\n")
    |> Enum.map(&String.split(&1," ", trim: true))
    |> Enum.reduce({1, 1, 20, 0, ""}, fn row, acc -> process_op(row, acc) end)
  end

  def process_op(["noop"], {x, cycle, checkpoint, sum, raster}) when checkpoint > 220 do
    {x, cycle + 1, checkpoint, sum, add_pixel(x, rem(cycle, 40), raster)}
  end

  def process_op(["addx", value], {x, cycle, checkpoint, sum, raster}) when checkpoint > 220 do
    {x + String.to_integer(value), cycle + 2, checkpoint, sum,
        add_pixel(x, rem(cycle + 1, 40), add_pixel(x, rem(cycle, 40), raster))}
  end

  def process_op(["noop"], {x, cycle, checkpoint, sum, raster}) when cycle >= checkpoint do
    {x, cycle + 1, checkpoint + 40, sum + checkpoint*x, add_pixel(x, rem(cycle, 40), raster)}
  end

  def process_op(["addx", value], {x, cycle, checkpoint, sum, raster}) when cycle >= checkpoint - 1 do
    {x + String.to_integer(value), cycle + 2, checkpoint + 40, sum + checkpoint*x,
        add_pixel(x, rem(cycle + 1, 40), add_pixel(x, rem(cycle, 40), raster))}
  end

  def process_op(["noop"], {x, cycle, checkpoint, sum, raster}) do
    {x, cycle + 1, checkpoint, sum, add_pixel(x, rem(cycle, 40), raster)}
  end

  def process_op(["addx", value], {x, cycle, checkpoint, sum, raster}) do
    {x + String.to_integer(value), cycle + 2, checkpoint, sum,
        add_pixel(x, rem(cycle + 1, 40), add_pixel(x, rem(cycle, 40), raster))}
  end

  # c is column, which is pos+1
  def add_pixel(x, c, raster) when c == x or c == x + 1 or c == x + 2 do
    eol(c, raster <> "#")
  end

  def add_pixel(_x, c, raster), do: eol(c, raster <> ".")

  def eol(c, raster) when c == 0, do: raster <> "\n"
  def eol(_c, raster), do: raster
end
