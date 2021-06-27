defmodule Objext do
  @moduledoc """
  Define a **fully-encapsulated** data structure (objext) module.
  "Fully-encapsulated" means that only the module that defines this objext can access its internal state.

  It's recommended to define a `new` function to return a new objext.
  You can pass any data to `buildo/1` function to build this new objext.

  ```
  defmodule ListQueue do
    use Objext

    def new(), do: buildo([])
  end
  ```

  Note that you should not depend on the internal structure of the data returned from `buildo/1`.
  It may be a tuple, a struct, a map, or a record.
  How it's implemented doesn't and shouldn't matter to you.
  You can use `matcho/1` macro to match the state in an objext:

  ```
  defmodule ListQueue do
    use Objext

    def new(), do: buildo([])

    def enqueue(matcho(state), item) do
      buildo(state ++ [item])
    end

    def dequeue(matcho([]) = this) do
      {:empty, this}
    end

    def dequeue(matcho([item | rest])) do
      {item, buildo(rest)}
    end
  end
  ```

  Finally, you can pass an `:implements` option to `use Objext`, specifying the interfaces/behaviours/protocols this module should implement.
  ```
  defmodule Queue do
    use Objext.Interface

    definterfaces do
      def enqueue(queue, item)
      def dequeue(queue)
    end
  end

  defmodule ListQueue do
    use Objext, implements: [Queue, Access, Enumerable]

    def new(), do: buildo([])

    @impl Queue
    def enqueue(matcho(state), item) do
      buildo(state ++ [item])
    end

    @impl Queue
    def dequeue(matcho([]) = this) do
      {:empty, this}
    end

    @impl Queue
    def dequeue(matcho([item | rest])) do
      {item, buildo(rest)}
    end

    @impl Access
    def fetch(matcho(list), index), do: Enum.at(list, index)

    @impl Enumerable
    def count(matcho(list)), do: length(list)
  end
  ```
  """

  defmacro __using__(opts) do
    implements = Keyword.get(opts, :implements, [])

    quote bind_quoted: [implements: implements] do
      implementation_module = __MODULE__

      interfaces = Enum.filter(implements, &Objext.Interface.is_interface/1)

      protocols = Enum.filter(implements, &Objext.Interface.is_protocol/1)

      behaviours = Enum.filter(implements, &Objext.Interface.is_behaviour/1)

      for interface <- interfaces do
        @behaviour interface.__interface__(:behaviour_module)
      end

      for protocol <- protocols do
        @behaviour protocol
      end

      for behaviour <- behaviours do
        @behaviour behaviour
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

        for protocol <- protocols do
          defimpl protocol do
            for {function, arity} <- protocol.__protocol__(:functions) do
              args = Macro.generate_unique_arguments(arity, __MODULE__)

              defdelegate unquote(function)(unquote_splicing(args)), to: implementation_module
            end
          end
        end

        for behaviour <- behaviours do
          @behaviour behaviour

          for {function, arity} <- behaviour.behaviour_info(:callbacks) do
            args = Macro.generate_unique_arguments(arity, __MODULE__)

            @impl behaviour
            defdelegate unquote(function)(unquote_splicing(args)), to: implementation_module
          end
        end

        def build(module, state), do: %__MODULE__{state: state}
      end
    end
  end
end
