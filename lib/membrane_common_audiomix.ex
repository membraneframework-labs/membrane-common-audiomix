defmodule Membrane.Common.AudioMix do
  @moduledoc """
  AudioMix is a simple module for mixing sounds
  """

  alias Membrane.Time
  alias Membrane.Caps.Audio.Raw, as: Caps
  use Membrane.Log, tags: :membrane_element_audiomix

  @doc """
  Takes the list of payloads containing audio samples and mixes them into one audio track.

  Expects the payloads to contain same amount of samples in the same format,
  described by caps parameter.
  """
  @spec mix_tracks(tracks :: [Membrane.Payload.t()], caps :: Caps.t()) :: binary
  def mix_tracks(tracks, caps) do
    start = Time.monotonic_time()

    sample_bytesize = caps |> Caps.sample_size()

    buffer =
      __MODULE__.Native.mix(
        tracks,
        Caps.signed?(caps),
        8 * sample_bytesize,
        Caps.big_endian?(caps)
      )

    finish = Time.monotonic_time()
    debug("Mixing time: #{(finish - start) |> Time.to_milliseconds()} ms")

    buffer
  end
end
