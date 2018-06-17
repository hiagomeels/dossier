defmodule Dossier.Mixfile do
  use Mix.Project

  @description """
  Dossier the way to parse string in schemas and vice versa.
  """
  @github "https://github.com/hiagomeels/dossier"

  def project do
    [
      app: :dossier,
      name: "Dossier",
      source_url: @github,
      homepage_url: nil,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: @description,
      package: package(),
      test_paths: ["test", "test/dossier"],
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.8", only: :docs, runtime: false}
    ]
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Hiagomeels"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github}
    ]
  end
end
