defmodule Multiset.Mixfile do
  use Mix.Project

  @version "0.0.4"

  def project do
    [app: :multiset,
     version: @version,
     elixir: "~> 1.2",
     name: "Multiset",
     source_url: "https://github.com/hilverd/multiset-elixir",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev},
     {:dialyxir, "~> 0.3", only: :dev}]
  end

  defp description do
    "Multisets for Elixir"
  end

  defp package do
    [maintainers: ["Hilverd Reker"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/hilverd/multiset-elixir"}]
  end
end
