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

