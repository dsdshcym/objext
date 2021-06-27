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
    test "enqueue |> dequeue follows `first in first out` order" do
      assert queue()
             |> Queue.enqueue(1)
             |> Queue.enqueue(2)
             |> Queue.enqueue(3)
             |> Queue.enqueue(4)
             |> Queue.to_list() == [1, 2, 3, 4]
    end
  end
end

defmodule ErlQueue do
  use Objext, implements: [Queue]

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

defmodule ListQueue do
  use Objext, implements: [Queue]

  def new() do
    buildo([])
  end

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
