defmodule Objext.MockTest do
  use ExUnit.Case, async: true

  describe "mock Objext interfaces" do
    test "expect & verify" do
      mock =
        Objext.Mock.new()
        |> Objext.Mock.expect(Queue, :enqueue, fn _mock, 1 -> :called end)

      assert Queue.enqueue(mock, 1) == :called

      Objext.Mock.verify!(mock)
    end

    test "stub" do
      mock =
        Objext.Mock.new()
        |> Objext.Mock.stub(Queue, :dequeue, fn _mock -> :called end)

      assert Queue.dequeue(mock) == :called
    end
  end

  describe "mock Protocol" do
    test "expect & verify" do
      mock =
        Objext.Mock.new()
        |> Objext.Mock.expect(Enumerable, :count, fn _mock -> :called end)

      assert Enumerable.count(mock) == :called

      Objext.Mock.verify!(mock)
    end

    test "stub" do
      mock =
        Objext.Mock.new()
        |> Objext.Mock.stub(Enumerable, :count, fn _mock -> :called end)

      assert Enumerable.count(mock) == :called
    end
  end
end
