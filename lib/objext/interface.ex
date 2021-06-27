defmodule Objext.Interface do
  @moduledoc """
  Define an interface module with callback functions.
  Each implementation module needs to implement these callback functions.
  It's similar to Protocol in many ways,
  except that you can also define other public functions in the same module.

  It's also recommended to use `defterms/2` macro in your interface modules.
  With `defterms/2`, you can define shared test cases.
  These shared cases can be reused in the implementation module tests.

  Example:
  ```
  defmodule Queue do
    use Objext.Interface

    definterfaces do
      def enqueue(queue, item)
      def dequeue(queue)
    end

    def to_list(queue) do
      case dequeue(queue) do
        {:empty, _} ->
          []

        {value, rest} ->
          [value | to_list(rest)]
      end
    end

    defterms subjects: [:queue] do
      describe "enqueue |> dequeue" do
        test "first in first out" do
          q1 = queue() |> Queue.enqueue(1) |> Queue.enqueue(2)
          assert {1, q2} = Queue.dequeue(q1)
          assert {2, q3} = Queue.dequeue(q2)
          assert {:empty, ^q3} = Queue.dequeue(q3)
        end
      end

      describe "enqueue |> to_list" do
        test "first in first out" do
          assert queue()
                 |> Queue.enqueue(1)
                 |> Queue.enqueue(2)
                 |> Queue.enqueue(3)
                 |> Queue.enqueue(4)
                 |> Queue.to_list() == [1, 2, 3, 4]
        end
      end
    end
  end

  defmodule ListQueueTest do
    use ExUnit.Case, async: true
    use Objext.Case, for: Queue, subjects: [queue: ListQueue.new()]
  end
  ```
  """
  defmacro __using__(_opts) do
    quote do
      import Objext.Interface, only: [definterfaces: 1]
      import Objext.Case, only: [defterms: 2]

      def __interface__(:module), do: __MODULE__
    end
  end

  defmacro definterfaces(do: block) do
    protocol_module = Module.concat(__CALLER__.module, Protocol)

    quote do
      def __interface__(:behaviour_module), do: unquote(protocol_module)
      def __interface__(:protocol_module), do: unquote(protocol_module)

      defprotocol unquote(protocol_module) do
        unquote(block)
      end

      for {function, arity} <- unquote(protocol_module).__protocol__(:functions) do
        unquote(__MODULE__).delegate_to({function, arity}, unquote(protocol_module))
      end

      for {function, arity} <- unquote(protocol_module).behaviour_info(:callbacks) do
      end
    end
  end

  @doc false
  defmacro delegate_to({function, arity}, to_mod) do
    quote bind_quoted: [function: function, arity: arity, to_mod: to_mod] do
      args = Macro.generate_unique_arguments(arity, __MODULE__)
      defdelegate unquote(function)(unquote_splicing(args)), to: to_mod
    end
  end

  def is_interface(module) do
    Code.ensure_loaded?(module) and
      function_exported?(module, :__interface__, 1) and
      module.__interface__(:module) == module
  end

  def is_protocol(module) do
    Code.ensure_loaded?(module) and
      function_exported?(module, :__protocol__, 1) and
      module.__protocol__(:module) == module
  end

  def is_behaviour(module) do
    Code.ensure_loaded?(module) and
      function_exported?(module, :behaviour_info, 1) and
      !is_protocol(module)
  end
end
