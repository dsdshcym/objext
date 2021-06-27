defmodule ObjextTest do
  use ExUnit.Case, async: true
  doctest Objext

  describe "interface module + implementation modules" do
    test "delegates interface functions to implementation modules" do
      assert StringValue.new() |> Value.a() == "a"
      assert AtomValue.new() |> Value.a() == :a
    end

    test "allows implementation module to implement other protocols" do
      assert inspect(StringValue.new()) == "a"
    end

    test "allows implementation module to implement other behaviours" do
      assert get_in(AtomValue.new(), [:a]) == true
    end
  end

  describe "implementation module only (as an opaque Struct)" do
    test "public functions can be called directly" do
      assert Plain.new() |> Plain.value() == :plain_value
    end
  end

  describe "cases defined in interface module can be reused" do
    use Objext.Case, for: Queue, subjects: [queue: ListQueue.new()]
  end
end
