defmodule Membrane.Common.AudioMix.NativeTest do
  use ExUnit.Case
  alias Membrane.Caps.Audio.Raw

  @module Membrane.Common.AudioMix.Native

  def call_mix(samples, format) do
    caps = %Raw{format: format}
    is_signed = Raw.signed?(caps)
    bitsize = 8 * Raw.sample_size(caps)
    is_big_endian = Raw.big_endian?(caps)

    samples
    |> Enum.map(&Raw.value_to_sample(&1, caps))
    |> @module.mix(is_signed, bitsize, is_big_endian)
    |> Raw.sample_to_value(caps)
  end

  def assert_mix(samples, format, value) do
    assert call_mix(samples, format) == value,
           "Mixing samples #{inspect(samples)} in format #{inspect(format)} " <>
             "should return #{value}"
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
end
