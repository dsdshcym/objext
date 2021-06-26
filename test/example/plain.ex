defmodule Plain do
  use Objext

  def new(), do: __MODULE__

  def value(_), do: :plain_value
end
