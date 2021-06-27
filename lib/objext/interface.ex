defmodule Objext.Interface do
  defmacro __using__(_opts) do
    quote do
      import Objext.Interface, only: [definterfaces: 1]

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
