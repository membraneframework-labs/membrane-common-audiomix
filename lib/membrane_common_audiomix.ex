defmodule Membrane.Common.AudioMix do
  @moduledoc """
  AudioMix is a simple module for mixing sounds
  """

  alias Membrane.Time
  alias Membrane.Caps.Audio.Raw, as: Caps
  use Membrane.Mixins.Log, tags: :membrane_element_audiomix
  use Membrane.Helper

  defp clipper_factory(caps) do
    max_sample_value = Caps.sample_max(caps)

    if Caps.signed?(caps) do
      min_sample_value = Caps.sample_min(caps)

      fn sample ->
        cond do
          sample > max_sample_value -> max_sample_value
          sample < min_sample_value -> min_sample_value
          true -> sample
        end
      end
    else
      fn sample ->
        if sample > max_sample_value do
          max_sample_value
        else
          sample
        end
      end
    end
  end

  defp do_mix(samples, mix_params, acc \\ 0)

  defp do_mix([], %{caps: caps, clipper: clipper}, acc) do
    acc |> clipper.() |> Caps.value_to_sample(caps)
  end

  defp do_mix([h | t], %{caps: caps} = mix_params, acc) do
    do_mix(t, mix_params, h |> Caps.sample_to_value(caps) ~> (v -> acc + v))
  end

  defp mix_params(caps) do
    %{caps: caps, clipper: clipper_factory(caps)}
  end

  defp zip_longest_binary_by(binaries, chunk_size, zipper, acc \\ []) do
    {chunks, rests} =
      binaries
      |> Enum.flat_map(fn
        <<chunk::binary-size(chunk_size)>> <> rest -> [{chunk, rest}]
        _ -> []
      end)
      |> Enum.unzip()

    case chunks do
      [] -> acc |> Enum.reverse() |> IO.iodata_to_binary()
      _ -> zip_longest_binary_by(rests, chunk_size, zipper, [zipper.(chunks) | acc])
    end
  end

  @doc """
  The only public function of the module. Gets a list of binaries of the same
  size and returns a binary, which is the result of mixing the list
  """
  @spec mix([binary], Caps.t()) :: binary
  def mix(buffers, caps) do
    sample_size = Caps.sample_size(caps)
    t = Time.monotonic_time()

    buffer =
      buffers
      |> zip_longest_binary_by(sample_size, fn buf -> do_mix(buf, caps |> mix_params) end)

    debug(
      "mixing time: #{(Time.monotonic_time() - t) |> Time.to_milliseconds()} ms, buffer size: #{
        byte_size(buffer)
      }"
    )

    buffer
  end
end
