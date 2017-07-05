defmodule Probe.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [app: :probe,
     version: @version,
     build_path: "_build",
     config_path: "config/config.exs",
     deps_path: "deps",
     lockfile: "mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     source_url: "https://github.com/strobe-audio/probe",
     description: description(),
     package: package(),
     name: "Probe",
     docs: [source_ref: "v#{@version}", main: "Probe"],
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end

  defp description do
    """
    A super-powered version of `IO.inspect` for better print debugging.
    """
  end

  defp package do
    [ maintainers: ["Garry Hill"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/strobe-audio/probe"}
    ]
  end
end
