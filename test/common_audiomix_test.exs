defmodule Membrane.Common.AudioMixTest do
  use ExUnit.Case
  import Bunch.Enum, only: [repeated: 2]
  alias Membrane.Caps.Audio.Raw

  @module Membrane.Common.AudioMix

  def call_mix(samples, format) do
    caps = %Raw{format: format}

    samples
    |> Enum.map(&Raw.value_to_sample(&1, caps))
    |> @module.mix_tracks(caps)
    |> Raw.sample_to_value(caps)
  end

  def assert_mix(samples, format, value) do
    result = call_mix(samples, format)

    assert result == value, """
    Mixing samples #{inspect(samples)} in format #{inspect(format)} \
    should return #{value}, got #{result} instead.
    """
  end

  def assert_mix_sum(samples, format) do
    assert_mix(samples, format, Enum.sum(samples))
  end

  test "Samples without overflow" do
    assert_mix_sum([12, 42], :u8)
    assert_mix_sum([12, 42], :u16le)
    assert_mix_sum([12, 42], :u16be)
    assert_mix_sum([12, 42], :u24le)
    assert_mix_sum([12, 42], :u24be)
    assert_mix_sum([12, 42], :u32le)
    assert_mix_sum([12, 42], :u32be)

    assert_mix_sum([12, 42], :s8)
    assert_mix_sum([12, 42], :s16le)
    assert_mix_sum([12, 42], :s16be)
    assert_mix_sum([12, 42], :s24le)
    assert_mix_sum([12, 42], :s24be)
    assert_mix_sum([12, 42], :s32le)
    assert_mix_sum([12, 42], :s32be)
  end

  test "Signed samples with negative values" do
    assert_mix_sum([12, -42], :s8)
    assert_mix_sum([12, -42], :s16le)
    assert_mix_sum([12, -42], :s16be)
    assert_mix_sum([12, -42], :s24le)
    assert_mix_sum([12, -42], :s24be)
    assert_mix_sum([12, -42], :s32le)
    assert_mix_sum([12, -42], :s32be)
  end

  def assert_clipped_max(samples, format) do
    assert_mix(samples, format, Raw.sample_max(%Raw{format: format}))
  end

  test "Samples where the sum exceedes max sample value" do
    assert_clipped_max([250, 42], :u8)
    assert_clipped_max([65_500, 123], :u16le)
    assert_clipped_max([65_500, 123], :u16be)
    assert_clipped_max([16_777_000, 456], :u24le)
    assert_clipped_max([16_777_000, 456], :u24be)
    assert_clipped_max([4_294_967_000, 456], :u32le)
    assert_clipped_max([4_294_967_000, 456], :u32be)

    assert_clipped_max([120, 42], :s8)
    assert_clipped_max([32_760, 42], :s16le)
    assert_clipped_max([32_760, 42], :s16be)
    assert_clipped_max([8_388_600, 42], :s24le)
    assert_clipped_max([8_388_600, 42], :s24be)
    assert_clipped_max([2_147_483_640, 42], :s32le)
    assert_clipped_max([2_147_483_640, 42], :s32be)
  end

  test "Samples where the sum exceedes max value more than once while summing" do
    assert_clipped_max(repeated(250, 8), :u8)
    assert_clipped_max(repeated(65_500, 8), :u16le)
    assert_clipped_max(repeated(65_500, 8), :u16be)
    assert_clipped_max(repeated(16_777_000, 8), :u24le)
    assert_clipped_max(repeated(16_777_000, 8), :u24be)
    assert_clipped_max(repeated(4_294_967_000, 8), :u32le)
    assert_clipped_max(repeated(4_294_967_000, 8), :u32be)

    assert_clipped_max(repeated(120, 8), :s8)
    assert_clipped_max(repeated(32_760, 8), :s16le)
    assert_clipped_max(repeated(32_760, 8), :s16be)
    assert_clipped_max(repeated(8_388_600, 8), :s24le)
    assert_clipped_max(repeated(8_388_600, 8), :s24be)
    assert_clipped_max(repeated(2_147_483_640, 8), :s32le)
    assert_clipped_max(repeated(2_147_483_640, 8), :s32be)
  end

  def assert_clipped_min(samples, format) do
    assert_mix(samples, format, Raw.sample_min(%Raw{format: format}))
  end

  test "Samples where the sum is smaller than min sample value" do
    assert_clipped_min([-120, -42], :s8)
    assert_clipped_min([-32_760, -42], :s16le)
    assert_clipped_min([-32_760, -42], :s16be)
    assert_clipped_min([-8_388_600, -42], :s24le)
    assert_clipped_min([-8_388_600, -42], :s24be)
    assert_clipped_min([-2_147_483_640, -42], :s32le)
    assert_clipped_min([-2_147_483_640, -42], :s32be)
  end

  test "Samples where the sum is smaller than min sample value more than once while summing" do
    assert_clipped_min(repeated(-120, 8), :s8)
    assert_clipped_min(repeated(-32_760, 8), :s16le)
    assert_clipped_min(repeated(-32_760, 8), :s16be)
    assert_clipped_min(repeated(-8_388_600, 8), :s24le)
    assert_clipped_min(repeated(-8_388_600, 8), :s24be)
    assert_clipped_min(repeated(-2_147_483_640, 8), :s32le)
    assert_clipped_min(repeated(-2_147_483_640, 8), :s32be)
  end
end
