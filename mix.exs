defmodule BetterstackLogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :betterstack_logger_backend,
      version: "0.11.1",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Betterstack Logger Backend",
      source_url: "https://github.com/towhans/betterstack_logger_backend",
      docs: [
        main: "readme",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BetterstackLogger.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:typed_struct, "~> 0.3.0"},
      {:bertex, "~> 1.3"},
      {:etso, "~> 1.1.0"},
      {:betterstack_api_client, "~> 0.3.5"},

      # Test and Dev
      {:placebo, "~> 2.0", only: :test},
      {:ex_doc, "~> 0.30.2", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:bypass, "~> 2.0", only: :test}
    ]
  end

  defp description() do
    "Easily ship structured logs and log based metrics to Betterstack with the Betterstack Logger backend."
  end

  defp package() do
    [
      links: %{"GitHub" => "https://github.com/towhans/betterstack_logger_backend"},
      licenses: ["MIT"]
    ]
  end
end
