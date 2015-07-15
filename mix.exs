defmodule Acache.Mixfile do
  use Mix.Project

  def project do
    [app: :acache,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications:  [
                      :logger,
                      :exactor,
                      :jazz,
                      :silverb,
                      :tinca
                    ],
     mod: {Acache, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:exactor, github: "sasa1977/exactor", tag: "0467f8100bc735405d597dbf94996195eb31e0b6", override: true},
      {:jazz, github: "meh/jazz"},
      {:silverb, github: "timCF/silverb"},
      {:tinca, github: "timCF/tinca"}
    ]
  end
end
