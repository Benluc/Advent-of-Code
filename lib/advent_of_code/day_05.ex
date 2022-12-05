defmodule AdventOfCode.Day05 do
  @moduledoc """
  --- Day 5: Supply Stacks ---
  The expedition can depart as soon as the final supplies have been unloaded from the ships. Supplies are stored in stacks of marked crates, but because the needed supplies are buried under many other crates, the crates need to be rearranged.

  The ship has a giant cargo crane capable of moving crates between stacks. To ensure none of the crates get crushed or fall over, the crane operator will rearrange them in a series of carefully-planned steps. After the crates are rearranged, the desired crates will be at the top of each stack.

  The Elves don't want to interrupt the crane operator during this delicate procedure, but they forgot to ask her which crate will end up where, and they want to be ready to unload them as soon as possible so they can embark.

  They do, however, have a drawing of the starting stacks of crates and the rearrangement procedure (your puzzle input). For example:

    [D]
  [N] [C]
  [Z] [M] [P]
  1   2   3

  move 1 from 2 to 1
  move 3 from 1 to 3
  move 2 from 2 to 1
  move 1 from 1 to 2
  In this example, there are three stacks of crates. Stack 1 contains two crates: crate Z is on the bottom, and crate N is on top. Stack 2 contains three crates; from bottom to top, they are crates M, C, and D. Finally, stack 3 contains a single crate, P.

  Then, the rearrangement procedure is given. In each step of the procedure, a quantity of crates is moved from one stack to a different stack. In the first step of the above rearrangement procedure, one crate is moved from stack 2 to stack 1, resulting in this configuration:

  [D]
  [N] [C]
  [Z] [M] [P]
  1   2   3
  In the second step, three crates are moved from stack 1 to stack 3. Crates are moved one at a time, so the first crate to be moved (D) ends up below the second and third crates:

        [Z]
        [N]
    [C] [D]
    [M] [P]
  1   2   3
  Then, both crates are moved from stack 2 to stack 1. Again, because crates are moved one at a time, crate C ends up below crate M:

        [Z]
        [N]
  [M]     [D]
  [C]     [P]
  1   2   3
  Finally, one crate is moved from stack 1 to stack 2:

        [Z]
        [N]
        [D]
  [C] [M] [P]
  1   2   3
  The Elves just need to know which crate will end up on top of each stack; in this example, the top crates are C in stack 1, M in stack 2, and Z in stack 3, so you should combine these together and give the Elves the message CMZ.

  After the rearrangement procedure completes, what crate ends up on top of each stack?
  """

  @doc """
          [C] [B] [H]
  [W]     [D] [J] [Q] [B]
  [P] [F] [Z] [F] [B] [L]
  [G] [Z] [N] [P] [J] [S] [V]
  [Z] [C] [H] [Z] [G] [T] [Z]     [C]
  [V] [B] [M] [M] [C] [Q] [C] [G] [H]
  [S] [V] [L] [D] [F] [F] [G] [L] [F]
  [B] [J] [V] [L] [V] [G] [L] [N] [J]
  1   2   3   4   5   6   7   8   9
  """
  @storage %{
    1 => ["W", "P", "G", "Z", "V", "S", "B"],
    2 => ["F", "Z", "C", "B", "V", "J"],
    3 => ["C", "D", "Z", "N", "H", "M", "L", "V"],
    4 => ["B", "J", "F", "P", "Z", "M", "D", "L"],
    5 => ["H", "Q", "B", "J", "G", "C", "F", "V"],
    6 => ["B", "L", "S", "T", "Q", "F", "G"],
    7 => ["V", "Z", "C", "G", "L"],
    8 => ["G", "L", "N"],
    9 => ["C", "H", "F", "J"]
  }
  @doc """
      [D]
  [N] [C]
  [Z] [M] [P]
  1   2   3
  """
  @min_storage %{
    1 => ["N", "Z"],
    2 => ["D", "C", "M"],
    3 => ["P"]
  }

  @min_commands [{1, 2, 1}, {3, 1, 3}, {2, 2, 1}, {1, 1, 2}]

  def part1(list) do
    list
    |> String.trim_trailing()
    |> String.split(~r/\n/)
    |> Enum.filter(&String.contains?(&1, "move"))
    |> Enum.map(&extract_commands/1)
    |> reorder_storage_with_commands(@storage)
    |> extract_crates_on_top()
    |> List.to_string()
  end

  defp extract_crates_on_top(storage) do
    storage
    |> Map.keys()
    |> Enum.map(&(Map.get(storage, &1) |> hd))
  end

  defp reorder_storage_with_commands([{value, from, to} | tail], storage, crane_modifier \\ 9000) do
    value_old_storage_location = Map.get(storage, from)

    value_new_storage_location = Map.get(storage, to)

    value_to_add_to_new_location =
      calculate_value_to_add_to_new_location(value_old_storage_location, value, crane_modifier)

    value_to_update_old_storage_location = Enum.drop(value_old_storage_location, value)

    updated_storage =
      storage
      |> Map.put(from, value_to_update_old_storage_location)
      |> Map.put(to, value_to_add_to_new_location ++ value_new_storage_location)

    reorder_storage_with_commands(tail, updated_storage, crane_modifier)
  end

  defp calculate_value_to_add_to_new_location(value_old_storage_location, value, 9000) do
    Enum.take(value_old_storage_location, value)
    |> Enum.reverse()
  end

  defp calculate_value_to_add_to_new_location(value_old_storage_location, value, 9001) do
    Enum.take(value_old_storage_location, value)
  end

  defp reorder_storage_with_commands([], storage, _), do: storage

  defp extract_commands(string) do
    string
    |> String.split()
    |> List.to_tuple()
    |> extract_numbers()
  end

  defp extract_numbers({_, value, _, from, _, to}) do
    {String.to_integer(value), String.to_integer(from), String.to_integer(to)}
  end

  def part2(list) do
    list
    |> String.trim_trailing()
    |> String.split(~r/\n/)
    |> Enum.filter(&String.contains?(&1, "move"))
    |> Enum.map(&extract_commands/1)
    |> reorder_storage_with_commands(@storage, 9001)
    |> extract_crates_on_top()
    |> List.to_string()
  end
end
