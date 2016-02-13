defmodule MultisetTest do
  use ExUnit.Case, async: true
  doctest Multiset

  alias Multiset, as: S

  test "using reduce" do
    list = [1, 2, 2, 3, 4, 4, 4]

    sum = list
    |> S.new
    |> Enum.reduce(0, fn {_value, multiplicity}, result -> result + multiplicity end)

    assert sum == Enum.count(list)
  end

  test "using member?" do
    list = [1, 2, 3, 4, 4, 7, 8, 8]
    multiset = list |> S.new

    for i <- 1..10 do
      assert Enum.member?(multiset, i) == Enum.member?(list, i)
    end
  end

  test "using count" do
    list = [1, 2, 3, 4, 4, 7, 8, 8]
    multiset = list |> S.new
    assert Enum.count(multiset) == Enum.count(list)
  end

  test "using into" do
    list = [1, 2, 3, 4, 4, 7, 8, 8]
    multiset = list |> Enum.into(S.new)
    assert S.to_list(multiset) == [{1, 1}, {2, 1}, {3, 1}, {4, 2}, {7, 1}, {8, 2}]
  end

  test "size of sum" do
    result = S.sum(S.new([1, 2, 2]), S.new([2, 3, 3]))
    assert S.size(result) == 6
  end

  test "size of union" do
    result = S.union(S.new([1, 2, 2]), S.new([2, 3, 3]))
    assert S.size(result) == 5
  end

  # The following tests are adapted from Elixir's map_set_test.exs

  test "new/1" do
    assert S.equal?(S.new(1..5), make([1, 2, 3, 4, 5]))
  end

  test "new/2" do
    assert S.equal?(S.new(1..3, fn x -> 2 * x end), make([1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3]))
  end

  test "put" do
    assert S.equal?(S.put(S.new, 1), S.new([1]))
    assert S.equal?(S.put(S.new([1, 3, 4]), 2), S.new(1..4))
    refute S.equal?(S.put(S.new(5..100), 10), S.new(5..100))
  end

  test "union" do
    assert S.equal?(S.union(S.new([1, 3, 4]), S.new), S.new([1, 3, 4]))
    assert S.equal?(S.union(S.new(5..15), S.new(10..25)), S.new(5..25))
    assert S.equal?(S.union(S.new(1..120), S.new(1..100)), S.new(1..120))
  end

  test "intersection" do
    assert S.equal?(S.intersection(S.new, S.new(1..21)), S.new)
    assert S.equal?(S.intersection(S.new(1..21), S.new(4..24)), S.new(4..21))
    assert S.equal?(S.intersection(S.new(2..100), S.new(1..120)), S.new(2..100))
  end

  test "difference" do
    assert S.equal?(S.difference(S.new(2..20), S.new), S.new(2..20))
    assert S.equal?(S.difference(S.new(2..20), S.new(1..21)), S.new)
    assert S.equal?(S.difference(S.new(1..101), S.new(2..100)), S.new([1, 101]))
  end

  test "subset?" do
    assert S.subset?(S.new, S.new)
    assert S.subset?(S.new(1..6), S.new(1..10))
    assert S.subset?(S.new(1..6), S.new(1..120))
    refute S.subset?(S.new(1..120), S.new(1..6))
  end

  test "equal?" do
    assert S.equal?(S.new, S.new)
    refute S.equal?(S.new(1..20), S.new(2..21))
    assert S.equal?(S.new(1..120), S.new(1..120))
  end

  test "delete" do
    assert S.equal?(S.delete(S.new, 1), S.new)
    assert S.equal?(S.delete(S.new(1..4), 5), S.new(1..4))
    assert S.equal?(S.delete(S.new(1..4), 1), S.new(2..4))
    assert S.equal?(S.delete(S.new(1..4), 2), S.new([1, 3, 4]))
  end

  test "size" do
    assert S.size(S.new) == 0
    assert S.size(S.new(5..15)) == 11
    assert S.size(S.new(2..100)) == 99
  end

  test "to_list" do
    assert S.to_list(S.new) == []

    list = S.to_list(S.new(5..120))
    assert Enum.sort(list) == Enum.map(5..120, fn x -> {x, 1} end)
  end

  defp make(collection), do: Enum.into(collection, S.new)
end
