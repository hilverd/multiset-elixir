# Multiset

[![Build Status](https://api.travis-ci.org/hilverd/multiset-elixir.svg?branch=master)](https://travis-ci.org/hilverd/multiset-elixir)
[![Hex.pm](https://img.shields.io/hexpm/v/multiset.svg?style=flat-square)](https://hex.pm/packages/multiset)
[![Hex.pm](https://img.shields.io/hexpm/dt/multiset.svg?style=flat-square)](https://hex.pm/packages/multiset)

This is an implementation of [multisets](https://en.wikipedia.org/wiki/Multiset) for
Elixir. Multisets are sets allowing multiple instances of values.

Documentation: http://hexdocs.pm/multiset.

## Usage

Add this library to your list of dependencies in `mix.exs`:

``` elixir
def deps do
  [{:multiset, "~> 0.0.3"}]
end
```

Then run `mix deps.get` in your shell to fetch and compile `multiset`.

## Examples

Start an interactive Elixir shell with `iex -S mix`.

``` elixir
iex> Multiset.new([1, 2, 1, 3])
#Multiset<[{1, 2}, {2, 1}, {3, 1}]>

iex> multiset1 = ~w(to be or not to be)a |> Multiset.new
#Multiset<[be: 2, not: 1, or: 1, to: 2]>

iex> multiset2 = ~w(neither a borrower nor a lender be)a |> Multiset.new
#Multiset<[a: 2, be: 1, borrower: 1, lender: 1, neither: 1, nor: 1]>

iex> Multiset.values(multiset1)
#MapSet<[:be, :not, :or, :to]>

iex> Multiset.intersection(multiset1, multiset2)
#Multiset<[be: 1]>

iex> Multiset.union(multiset1, multiset2)
#Multiset<[a: 2, be: 2, borrower: 1, lender: 1, neither: 1, nor: 1, not: 1, or: 1, to: 2]>

iex> Multiset.sum(multiset1, multiset2)
#Multiset<[a: 2, be: 3, borrower: 1, lender: 1, neither: 1, nor: 1, not: 1, or: 1, to: 2]>
```

See the [documentation](http://hexdocs.pm/multiset) for more available functionality.
