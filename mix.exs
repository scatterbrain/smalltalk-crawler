defmodule SmalltalkCrawler.Mixfile do
  use Mix.Project

  def project do
    [app: :smalltalk_crawler,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env != :local && Mix.env != :test,
     start_permanent: Mix.env != :local && Mix.env != :test,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {SmalltalkCrawler, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :postgrex, :httpoison, :feeder_ex, :floki,
                  :hedwig, :exml, :tzdata
                  ]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.0.3"},
     {:phoenix_ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :local},
     {:cowboy, "~> 1.0"}, 
     {:feeder_ex, github: "scatterbrain/feeder_ex",  branch: :master}, 
     {:httpoison, "~> 0.8.0"}, 
     {:floki, "~> 0.7"}, 
     {:hedwig, "~> 0.3.0"},
     {:exml, github: "paulgray/exml"}, 
     {:timex, "~> 0.19.2"}
   ]
  end
end
