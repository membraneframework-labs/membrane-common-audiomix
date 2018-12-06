defmodule Membrane.Common.AudioMix do
  @moduledoc """
  AudioMix is a simple module for mixing sounds
  """

  alias Membrane.Time
  alias Membrane.Caps.Audio.Raw, as: Caps
  use Membrane.Log, tags: :membrane_element_audiomix

  @doc """
  Takes the list of payloads containing audio samples and mixes them into one audio stream.

  Expects the payloads to contain same amount of samples in the same format,
  described by caps parameter.
  """
  @spec mix_streams(streams :: [Membrane.Payload.t()], caps :: Caps.t()) :: binary
  def mix_streams(streams, caps) do
    start = Time.monotonic_time()

    sample_bytesize = caps |> Caps.sample_size()

    buffer =
      __MODULE__.Native.mix(
        streams,
        Caps.signed?(caps),
        8 * sample_bytesize,
        Caps.big_endian?(caps)
      )

    finish = Time.monotonic_time()
    mixing_time = (finish - start) |> Time.to_milliseconds()

    if mixing_time >= 100 do
      warn("""
      Mixing in NIF took #{mixing_time} ms. NIFs MUST NOT execute that long.
      Consider mixing smaller chunks of data.
      """)
    else
      debug("Mixing time: #{mixing_time} ms")
    end

    buffer
  end
end
