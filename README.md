# Multiset

This is an implementation of [multisets](https://en.wikipedia.org/wiki/Multiset) for
Elixir. Multisets are sets allowing multiple instances of values.

Documentation: http://hexdocs.pm/multiset/.

## Usage

Add this library to your list of dependencies in `mix.exs`:

``` elixir
def deps do
  [{:multiset, "~> 0.0.1"}]
end
```

Then run `mix deps.get` in your shell to fetch and compile `multiset`.

## Examples

``` elixir
iex> multiset = Multiset.new([:b, :a, 3, :a])
#Multiset<[{3, 1}, {:a, 2}, {:b, 1}]>

iex> multiset |> Multiset.put(:c) |> Multiset.put(:c)
#Multiset<[{3, 1}, {:a, 2}, {:b, 1}, {:c, 2}]>
```
