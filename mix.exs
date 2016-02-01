defmodule Defmock.Mixfile do
  use Mix.Project

  @project_url "https://github.com/turbomates/defmock"
  @version "0.0.1"

  def project do
   [
     app: :defmock,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Elixir mock/stub module helper",
     source_url: @project_url,
     homepage_url: @project_url,
     package: package,
     docs: [main: "README", extras: ["README.md"]],
     deps: deps
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: []
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

  defp package do
    [
      links: %{"GitHub" => @project_url}
    ]
  end
end
