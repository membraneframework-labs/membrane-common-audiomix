defmodule Membrane.Common.AudioMix.Native do
  use Unifex.Loader
  alias Membrane.Time
  alias Membrane.Caps.Audio.Raw, as: Caps

  use Membrane.Log, tags: :membrane_element_audiomix

  def mix_wrapper(buffers, caps) do
    start = Time.monotonic_time()

    IO.puts("Caps: #{inspect caps}")

    is_signed = if caps |> Caps.signed?, do: 1, else: 0
    sample_size = caps |> Caps.sample_size
    endianness = if caps |> Caps.big_endian?, do: 1, else: 0

    buffer = mix(buffers, is_signed, 8 * sample_size, endianness)

    finish = Time.monotonic_time()
    info("Mixing time: #{(finish - start) |> Time.to_milliseconds}")
    buffer
  end
end
