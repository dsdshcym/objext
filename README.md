# Objext

Objext helps you define **fully-encapsulated** data structures (so called "objexts").
Then Objext allows you to define a common interfaces for these "objexts".
Objext will **dynamically dispatch** the interfaces function calls to implementation functions (just like Protocol does).
Finally, these data structures and interfaces defined by Objext are fully **compatible** with existing Protocols and Behaviours.

## Goals

Objext is designed to help you define your Abstract Data Types, with an easy to use API.
To achieve this objective, Objext keeps the following goals in mind:

1. **Encapsulated**

   The data structure defined with `use Objext` should be 100% opaque to the other modules.
   I hope this feature can guide you to design data structures as [Abstract Data Types (ADTs)](https://en.wikipedia.org/wiki/Abstract_data_type) in Elixir.
   ADTs are defined solely by what public functions can operate on them and what would happen/return when calling these functions.
   ADTs' internal structures are just implementation details and can be refactored in one place.

2. **Incremental**

   With Objext, you can start designing your system from outside in.
   Solidify your public API at interface level first, then add implementation modules.

   You can also design your system from ground up.
   Incrementally refactor a normal Elixir module to an interface module plus an implementation module.
   And then add more implementation modules.

   See the Example section below for more details.

3. **Easy-to-test**

   An ADT is not defined by its internal data structure but the behaviours of its public functions (`terms`).
   So we need to test if an implementation follows these `terms`.
   Objext lets you define reusable `terms` along side your interface module.
   Inside these `terms`, you can use your familiar `ExUnit.Case.describe/2` and `ExUnit.Case.test/3` macro to define tests.
   Then you can reuse these `terms` in each implementation module's test.

4. **Mockable**

   Once you have an interface defined, you can use `Objext.Mock` to create mocks for this interface.
   So you can simplify your test for those code that depends on this interface.

5. **Compatible with existing tooling/ecosystem**

   Elixir and Erlang ecosystem have already provided us many powerful tools.
   Elixir compiler emits warnings if you forget to implement a callback function.
   Dialyzer emits warnings if you peek into an opaque type.
   So Objext won't reinvent these wheels again.
   Instead, Objext will leverage these existing tools to provide the best developer experience.

   Plus, Objext allows you to define implementations for existing Protocols (e.g. `Inspect`) and Behaviours (e.g. `Access`).
   So you don't need to migrate from Protocol to Objext overnight.

## Example

### Inside-out approach

1. At first, you may only have one `Queue` module.
   And you can just play with the public APIs until they are stable.
   ``` elixir
   defmodule Queue do
     def new(), do: []

     def enqueue(queue, item), do: queue ++ [item]

     def dequeue([]), do: {:empty, []}
     def dequeue([item | rest]), do: {item, rest}
   end
   ```
2. When you feel the APIs are quite stable, you can converting it to an Objext module so it's now opaque to the other modules.
   The cost of this encapsulation is that you need to use the `buildo` macro to return a new objext (with the same "class"), and use the `matcho` macro to match the internal state of this "class" of objexts.
   ``` elixir
   defmodule Queue do
     use Objext

     def new(), do: buildo([])

     def enqueue(matcho(queue), item), do: buildo(queue ++ [item])

     def dequeue(matcho([]) = this), do: {:empty, this}
     def dequeue(matcho([item | rest])), do: {item, buildo(rest)}
   end
   ```
3. Then you may need to introduce a new `Queue` implementation.
   You can define the interfaces and the implementations in the same `Queue` module.
   And all the existing (client) code should just work as expected.
   ``` elixir
   defmodule Queue do
     use Objext, implements: [Queue]
     use Objext.Interface

     definterfaces do
       def enqueue(queue, item)

       def dequeue(queue)
     end

     def new(), do: buildo([])

     def enqueue(matcho(queue), item), do: buildo(queue ++ [item])

     def dequeue(matcho([]) = this), do: {:empty, this}
     def dequeue(matcho([item | rest])), do: {item, buildo(rest)}
   end
   ```
4. And then you can gradually extracting the old implementation to a separated module.
   ``` elixir
   defmodule Queue do
     use Objext.Interface

     definterfaces do
       def enqueue(queue, item)

       def dequeue(queue)
     end
   end

   defmodule ListQueue do
     use Objext, implements: [Queue]

     def new(), do: buildo([])

     def enqueue(matcho(queue), item), do: buildo(queue ++ [item])

     def dequeue(matcho([]) = this), do: {:empty, this}
     def dequeue(matcho([item | rest])), do: {item, buildo(rest)}
   end
   ```
5. Meanwhile, you may reuse the existing test cases to define `terms` for the `Queue` interface.
   So any new `Queue` implementations can be assured to pass the same test suites.
   ``` elixir
   defmodule Queue do
     use Objext.Interface

     definterfaces do
       def enqueue(queue, item)

       def dequeue(queue)
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
6. Finally, you can introduce a new module that implements the `Queue` interface:
   ``` elixir
   defmodule ErlQueue do
     use GenObject, implements: [Queue]

     def new() do
       buildo(:queue.new())
     end

     def enqueue(matcho(state), item) do
       buildo(:queue.in(item, state))
     end

     def dequeue(matcho(state)) do
       case :queue.out(state) do
         {{:value, item}, new_state} ->
           {item, buildo(new_state)}

         {:empty, new_state} ->
           {:empty, buildo(new_state)}
       end
     end
   end

   defmodule ErlQueueTest do
     use ExUnit.Case, async: true
     use Objext.Case, for: Queue, subjects: [queue: ErlQueue.new()]
   end
   ```

### TODO Outside-In Approach

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `objext` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:objext, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/objext](https://hexdocs.pm/objext).


## Road-map
1. [ ] Put Internal modules like `*.Protocol` and `*.Object` under Objext namespace (avoid polluting user namespaces)
2. [ ] Boundary-like compile time check for encapsulation violations
3. [ ] Eliminate the needs of delegating to protocols (simpler internal structure, better performance)
