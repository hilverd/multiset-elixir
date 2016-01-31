defmodule MultisetTest do
  use ExUnit.Case
  doctest Multiset

  test "using reduce" do
    list = [1, 2, 2, 3, 4, 4, 4]

    sum = list
    |> Multiset.new
    |> Enum.reduce(0, fn {_value, multiplicity}, result -> result + multiplicity end)

    assert sum == Enum.count(list)
  end

  test "using member?" do
    list = [1, 2, 3, 4, 4, 7, 8, 8]
    multiset = list |> Multiset.new

    for i <- 1..10 do
      assert Enum.member?(multiset, i) == Enum.member?(list, i)
    end
  end

  test "using count" do
    list = [1, 2, 3, 4, 4, 7, 8, 8]
    multiset = list |> Multiset.new
    assert Enum.count(multiset) == Enum.count(list)
  end

  test "using into" do
    list = [1, 2, 3, 4, 4, 7, 8, 8]
    multiset = list |> Enum.into(Multiset.new)
    assert Multiset.to_list(multiset) == [{1, 1}, {2, 1}, {3, 1}, {4, 2}, {7, 1}, {8, 2}]
  end

  test "size of sum" do
    result = Multiset.sum(Multiset.new([1, 2, 2]), Multiset.new([2, 3, 3]))
    assert Multiset.size(result) == 6
  end

  test "size of union" do
    result = Multiset.union(Multiset.new([1, 2, 2]), Multiset.new([2, 3, 3]))
    assert Multiset.size(result) == 5
  end
end
