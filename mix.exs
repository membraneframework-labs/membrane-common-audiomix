defmodule MembraneCommonAudiomix.MixProject do
  use Mix.Project

  def project do
    [
      app: :membrane_common_audiomix,
      compilers: [:unifex, :bundlex] ++ Mix.compilers,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:membrane_core, "~> 0.2.0"},
      {:membrane_loggers, "~> 0.2.0"},
      {:membrane_caps_audio_raw, "~> 0.1.3"},
      {:bunch, "~> 0.1.2"},
      {:bundlex, "~> 0.1.4"},
      {:unifex, "~> 0.1.0"}
    ]
  end
end
