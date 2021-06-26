defmodule ObjextTest do
  use ExUnit.Case, async: true
  doctest Objext

  describe "implementation module only (as an opaque Struct)" do
    test "public functions can be called directly" do
      assert Plain.new() |> Plain.value() == :plain_value
    end
  end
end
