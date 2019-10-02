defmodule MembraneCommonAudiomix.MixProject do
  use Mix.Project

  @version "0.1.1"
  @github_url "https://github.com/membraneframework/membrane-common-audiomix"

  def project do
    [
      app: :membrane_common_audiomix,
      compilers: [:unifex, :bundlex] ++ Mix.compilers(),
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      }
    ]
  end

  defp deps do
    [
      {:membrane_core, "~> 0.4.1"},
      {:membrane_loggers, "~> 0.2.6"},
      {:membrane_caps_audio_raw, "~> 0.1.8"},
      {:bunch, "~> 1.1"},
      {:bundlex, "~> 0.2.0"},
      {:unifex, "~> 0.2.0"}
    ]
  end
end
