defmodule Day07 do
  @input "input-07.txt"

  def part1() do
    get_sizes_list()
    |> Enum.reject(fn x -> x > 100000 end)
    |> Enum.sum
  end

  def part2() do
    sizes = Enum.sort(get_sizes_list())

    sizes
    |> Enum.find(fn x -> x > List.last(sizes, 1) - 40000000 end)
  end

  def get_sizes_list() do
    @input
    |> File.read!
    |> String.split("$ ", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.reduce({%{"/" => %{}}, ["/"]}, fn group, acc -> process_command(group, acc) end)
    |> (&elem(&1, 0)).()
    |> sum_file_sizes()
  end

  def process_command(["cd /"], {tree, _}),  do: {tree, ["/"]}

  def process_command(["cd .."], {tree, current_path}) do
    current_path
    |> Enum.reverse()
    |> tl
    |> Enum.reverse()
    |> (&{tree, &1}).()
  end

  def process_command(["cd " <> dir_name], {tree, current_path}) do
    {tree, current_path ++ [dir_name]}
  end

  def process_command(["ls" | tail], {tree, current_path}) do
    tail
    |> Enum.reduce(tree, fn s, acc -> add_directory_item(s, acc, current_path)  end)
    |> (&{&1, current_path}).()
  end

  def add_directory_item("dir " <> dir_name, tree, current_path) do
    put_in(tree, current_path,
        Map.merge(get_in(tree, current_path), %{dir_name => %{}}))
  end

  def add_directory_item(item, tree, current_path) do
    [size, filename] = String.split(item, " ")
    put_in(tree, current_path,
        Map.merge(get_in(tree, current_path), %{filename => String.to_integer(size)}))
  end

  def sum_file_sizes(number) when is_integer(number) do
    [number]
  end

  def sum_file_sizes(tree) do
    tree
    |> Map.values()
    |> Enum.reduce([0], fn value, acc -> list = sum_file_sizes(value)
        [hd(acc) + hd(list) | tl(acc) ++ tl(list)] end)
    |> (&[hd(&1) | &1]).()
  end
end
