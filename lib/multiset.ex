defmodule Multiset do
  @moduledoc """
  Functions for working with [multisets](https://en.wikipedia.org/wiki/Multiset), i.e. sets allowing
  multiple instances of values.

  The number of instances of a value in a multiset is called the _multiplicity_ of the value.

  The `Multiset` is represented internally as a struct, therefore `%Multiset{}` can be used whenever
  there is a need to match on any `Multiset`. Note though the struct fields are private and must not
  be accessed directly.  Instead, use the functions in this module.
  """

  @opaque t :: %Multiset{map: map}
  @type value :: term
  defstruct map: %{}, size: 0

  @doc """
  Returns a new multiset.

  ## Examples

      iex> Multiset.new
      #Multiset<[]>
  """
  @spec new :: t
  def new(), do: %Multiset{}

  @doc """
  Creates a multiset from an enumerable.

  ## Examples

      iex> Multiset.new([:b, :a, 3, :a])
      #Multiset<[{3, 1}, {:a, 2}, {:b, 1}]>
      iex> Multiset.new([3, 3, 2, 2, 1])
      #Multiset<[{1, 1}, {2, 2}, {3, 2}]>
  """
  @spec new(Enum.t) :: t
  def new(enumerable), do: Enum.reduce(enumerable, %Multiset{}, &put(&2, &1))

  @doc """
  Creates a multiset from an enumerable via a function that assigns multiplicities.

  If `multiplicities` returns an integer < 1 for a value, then that value is not added to the
  multiset.

  ## Examples

      iex> Multiset.new([1, 2, 3], fn x -> x - 1 end)
      #Multiset<[{2, 1}, {3, 2}]>
  """
  @spec new(Enum.t, (term -> integer)) :: t
  def new(enumerable, multiplicities) do
    Enum.reduce(enumerable, %Multiset{}, fn value, result ->
      put(result, value, multiplicities.(value))
    end)
  end

  @doc """
  Creates a multiset from a list of pairs of values and their multiplicities.

  ## Examples

  iex> Multiset.from_list([{1, 3}, {2, 4}, {3, 0}])
  #Multiset<[{1, 3}, {2, 4}]>
  """
  @spec from_list([{t, pos_integer}]) :: t
  def from_list(pairs) do
    Enum.reduce(pairs, new, fn {value, multiplicity}, result ->
      put(result, value, multiplicity)
    end)
  end

  @doc """
  Deletes `k` (by default 1) instances of `value` from `multiset`.

  Returns a new multiset which is a copy of `multiset` but with `k` fewer instance of `value`.

  ## Examples

      iex> multiset = Multiset.new([1, 2, 3, 3])
      iex> Multiset.delete(multiset, 3, 2)
      #Multiset<[{1, 1}, {2, 1}]>
      iex> Multiset.delete(multiset, 3)
      #Multiset<[{1, 1}, {2, 1}, {3, 1}]>
  """
  @spec delete(t, value, integer) :: t
  def delete(multiset, value, k \\ 1)
  def delete(%Multiset{map: map} = multiset, value, k) do
    cur_multiplicity = Map.get(map, value, 0)
    new_multiplicity = max(0, cur_multiplicity - k)
    new_size = multiset.size - (cur_multiplicity - new_multiplicity)
    if new_multiplicity == 0 do
      %{multiset | map: Map.delete(map, value), size: new_size}
    else
      %{multiset | map: Map.put(map, value, new_multiplicity), size: new_size}
    end
  end

  @doc """
  Returns a multiset that is `multiset1` without the (instances of) values of `multiset2`.

  ## Examples

      iex> Multiset.difference(Multiset.new([1, 2, 2, 3, 3]), Multiset.new([1, 1, 2, 4]))
      #Multiset<[{2, 1}, {3, 2}]>
  """
  @spec difference(t, t) :: t
  def difference(multiset1, multiset2)
  def difference(%Multiset{} = multiset1, %Multiset{map: map2}) do
    :maps.fold(fn value, multiplicity, result -> delete(result, value, multiplicity) end,
               multiset1, map2)
  end

  @doc """
  Checks if two multisets are equal.

  The comparison between values must be done using `===`.

  ## Examples

      iex> Multiset.equal?(Multiset.new([1, 2]), Multiset.new([2, 1]))
      true
      iex> Multiset.equal?(Multiset.new([1, 2]), Multiset.new([1, 1, 2]))
      false
  """
  @spec equal?(t, t) :: boolean
  def equal?(multiset1, multiset2)
  def equal?(%Multiset{map: map1}, %Multiset{map: map2}), do: Map.equal?(map1, map2)

  @doc """
  Returns a multiset containing only (instances of) members that `multiset1` and `multiset2` have in
  common.

  ## Examples

      iex> Multiset.intersection(Multiset.new([1, 2, 2, 2, 3]), Multiset.new([2, 2, 3, 3, 4]))
      #Multiset<[{2, 2}, {3, 1}]>
  """
  @spec intersection(t, t) :: t
  def intersection(multiset1, multiset2)
  def intersection(%Multiset{map: map1}, %Multiset{map: map2}) do
    if map_size(map1) > map_size(map2), do: {map1, map2} = {map2, map1}

    :maps.fold(fn value, multiplicity, result ->
      new_multiplicity = min(multiplicity, Map.get(map2, value, 0))
      put(result, value, new_multiplicity)
    end, new, map1)
  end

  @doc """
  Checks if `multiset` contains at least one instance of `value`.

  ## Examples

      iex> Multiset.member?(Multiset.new([1, 2, 3]), 2)
      true
      iex> Multiset.member?(Multiset.new([1, 2, 3]), 4)
      false
  """
  @spec member?(t, value) :: boolean
  def member?(multiset, value), do: multiplicity(multiset, value) > 0

  @doc """
  Returns the multiplicity of `value` in `multiset`.

  ## Examples

      iex> Multiset.multiplicity(Multiset.new([1, 2, 3, 1]), 1)
      2
      iex> Multiset.multiplicity(Multiset.new([1, 2, 3]), 4)
      0
  """
  @spec multiplicity(t, value) :: non_neg_integer
  def multiplicity(multiset, value)
  def multiplicity(%Multiset{map: map}, value), do: Map.get(map, value, 0)

  @doc """
  Inserts `k` (by default 1) instances of `value` into `multiset`.

  Returns a new multiset which is a copy of `multiset` but with `k` more instance of `value`.

  ## Examples

      iex> multiset = Multiset.new([1, 2])
      iex> Multiset.put(multiset, 3, 2)
      #Multiset<[{1, 1}, {2, 1}, {3, 2}]>
      iex> Multiset.put(multiset, 1)
      #Multiset<[{1, 2}, {2, 1}]>
  """
  @spec put(t, value, integer) :: t
  def put(multiset, value, k \\ 1)
  def put(%Multiset{map: map, size: size} = multiset, value, k) do
    if k < 1 do
      multiset
    else
      new_map = Map.update(map, value, k, fn multiplicity -> multiplicity + k end)
      new_size = size + k
      %{multiset | map: new_map, size: new_size}
    end
  end

  @doc """
  Returns the number of (instances of) values in `multiset`.

  ## Examples

      iex> Multiset.size(Multiset.new([1, 2, 2]))
      3
  """
  @spec size(t) :: non_neg_integer
  def size(multiset), do: multiset.size

  @doc """
  Checks if `multiset1`'s values all have a smaller (or equal) multiplicity as the corresponding
  values in `multiset2`.

  ## Examples

      iex> Multiset.subset?(Multiset.new([1, 1, 2]), Multiset.new([1, 1, 2, 2, 3]))
      true
      iex> Multiset.subset?(Multiset.new([1, 1, 2]), Multiset.new([1, 2, 3]))
      false
  """
  @spec subset?(t, t) :: boolean
  def subset?(multiset1, multiset2)
  def subset?(%Multiset{map: map1}, %Multiset{map: map2} = multiset2) do
    if map_size(map1) <= map_size(map2) do
      :maps.fold(fn value, multiplicity, _ ->
        if multiplicity <= multiplicity(multiset2, value) do
          true
        else
          throw({:halt, false})
        end
      end, true, map1)
    else
      false
    end
  catch
    {:halt, false} -> false
  end

  @doc """
  Returns the multiset sum of `multiset1` and `multiset2`.

  ## Examples

      iex> Multiset.sum(Multiset.new([1, 2, 2]), Multiset.new([2, 3, 3]))
      #Multiset<[{1, 1}, {2, 3}, {3, 2}]>
  """
  @spec sum(t, t) :: t
  def sum(multiset1, multiset2)
  def sum(%Multiset{map: map1}, %Multiset{map: map2}) do
    new_map = Map.merge(map1, map2, fn _value, multiplicity1, multiplicity2 ->
      multiplicity1 + multiplicity2
    end)

    %Multiset{map: new_map}
  end

  @doc """
  Converts `multiset` to a list of pairs of values and their multiplicities.

  ## Examples

      iex> Multiset.to_list(Multiset.new([1, 2, 3, 1]))
      [{1, 2}, {2, 1}, {3, 1}]
  """
  @spec to_list(t) :: [{t, pos_integer}]
  def to_list(multiset)
  def to_list(%Multiset{map: map}), do: Map.to_list(map)

  @doc """
  Returns the multiset union of `multiset1` and `multiset2`.

  ## Examples

      iex> Multiset.union(Multiset.new([1, 2, 2]), Multiset.new([2, 3, 3]))
      #Multiset<[{1, 1}, {2, 2}, {3, 2}]>
  """
  @spec union(t, t) :: t
  def union(multiset1, multiset2)
  def union(%Multiset{map: map1}, %Multiset{map: map2}) do
    new_map = Map.merge(map1, map2, fn _value, multiplicity1, multiplicity2 ->
      max(multiplicity1, multiplicity2)
    end)

    %Multiset{map: new_map}
  end

  @doc """
  Returns the values in `multiset` as a `MapSet`.

  ## Examples

      iex> Multiset.values(Multiset.new([1, 2, 2, 3]))
      MapSet.new([1, 2, 3])
  """
  @spec values(t) :: MapSet.t
  def values(multiset)
  def values(%Multiset{map: map}), do: map |> Map.keys |> MapSet.new

  defimpl Enumerable do
    def reduce(set, acc, fun), do: Enumerable.List.reduce(Multiset.to_list(set), acc, fun)
    def member?(set, val),     do: {:ok, Multiset.member?(set, val)}
    def count(set),            do: {:ok, Multiset.size(set)}
  end

  defimpl Collectable do
    def into(original) do
      {original, fn
        set, {:cont, x} -> Multiset.put(set, x)
        set, :done -> set
        _, :halt -> :ok
      end}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(multiset, opts) do
      concat ["#Multiset<", Inspect.List.inspect(Multiset.to_list(multiset), opts), ">"]
    end
  end
end
