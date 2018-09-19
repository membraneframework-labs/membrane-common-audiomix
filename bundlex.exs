defmodule Membrane.Common.AudioMix.BundlexProject do
  use Bundlex.Project

  def project() do
    [
      nifs: nifs(Bundlex.platform)
    ]
  end

  defp nifs(_platform) do
    [
      mix: [
        deps: [membrane_common_c: :membrane, unifex: :unifex],
        sources: ["_generated/mix.c", "mix.c"]
      ]
    ]
  end
end
