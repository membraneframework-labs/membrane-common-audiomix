defmodule Membrane.Common.AudioMix.Native do
  use Unifex.Loader
  alias Membrane.Time

  use Membrane.Mixins.Log, tags: :membrane_element_audiomix

  def mix_wrapper(buffers) do
    start = Time.monotonic_time()
    buffer = mix(buffers)
    finish = Time.monotonic_time()
    info("Mixing time: #{(finish - start) |> Time.to_milliseconds}")
    buffer
  end
end
