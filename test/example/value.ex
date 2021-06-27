defmodule Value do
  use Objext.Interface

  definterfaces do
    def a(value)
  end
end

defmodule StringValue do
  use Objext, implements: [Value, Inspect]

  def new() do
    buildo()
  end

  def a(_), do: "a"

  def inspect(_, _opts), do: "a"
end

defmodule AtomValue do
  use Objext, implements: [Value, Access]

  def new() do
    buildo()
  end

  def a(_), do: :a

  def fetch(_, :a), do: {:ok, true}

  def get_and_update(this, :a, _), do: {true, this}

  def pop(this, :a), do: {true, this}
end
