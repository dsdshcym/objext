defmodule Objext do
  @moduledoc """
  Documentation for `Objext`.
  """

  defmacro __using__(opts) do
    implements = Keyword.get(opts, :implements, [])

    quote bind_quoted: [implements: implements] do
      implementation_module = __MODULE__

      interfaces = implements

      for interface <- interfaces do
        @behaviour interface.__interface__(:behaviour_module)
      end

      defp buildo(state \\ __MODULE__) do
        __MODULE__.Object.build(__MODULE__, state)
      end

      defmacrop matcho(pattern) do
        quote do
          %__MODULE__.Object{state: unquote(pattern)}
        end
      end

      defmodule Object do
        defstruct [:state]

        @opaque t() :: %__MODULE__{}

        for interface <- interfaces do
          protocol = interface.__interface__(:protocol_module)

          defimpl protocol do
            for {function, arity} <- protocol.__protocol__(:functions) do
              args = Macro.generate_unique_arguments(arity, __MODULE__)

              defdelegate unquote(function)(unquote_splicing(args)), to: implementation_module
            end
          end
        end

        def build(module, state), do: %__MODULE__{state: state}
      end
    end
  end
end
