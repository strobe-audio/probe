defmodule ProbeTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  require Probe

  def output(line) do
    IO.ANSI.format_fragment([line | "\n" ]) |> IO.iodata_to_binary
  end

  test "Probe.d" do
    assert capture_io(fn ->
      Probe.d(:something)
    end) == output([:reverse, " :something ", :reset, " :something"])
  end

  test "Probe.i" do
    assert capture_io(fn ->
      Probe.i(:something)
    end) == output([:reverse, " :something ", :reset, " :something"])
  end

  test "Probe.red" do
    assert capture_io(fn ->
      Probe.red("house", :house)
    end) == output([:red, " :house ", :reset, " \"house\""])
  end

  test "Probe.blue" do
    assert capture_io(fn ->
      Probe.blue("house", "house")
    end) == output([:blue, " house ", :reset, " \"house\""])
  end

  def monkey(food) do
    [:eat, food]
  end

  test "Probe.green" do
    assert capture_io(fn ->
      :banana |> monkey() |> Probe.green()
    end) == output([:green, " monkey(:banana) ", :reset, " [:eat, :banana]"])
  end
end
