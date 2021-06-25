# Objext

Objext helps you define **fully-encapsulated** data structures (so called "objexts").
Then Objext allows you to define a common interfaces for these "objexts".
Objext will **dynamically dispatch** the interfaces function calls to implementation functions (just like Protocol does).
Finally, these data structures and interfaces defined by Objext are fully **compatible** with existing Protocols and Behaviours.

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

