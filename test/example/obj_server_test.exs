defmodule ObjServer do
  use Objext.Interface

  definterfaces do
    def init(init_arg)
    def handle_cast(request, state)
    def handle_call(request, from, state)
  end

  use Objext

  def start_link(mod, init_args) do
    server = buildo(%{mod: mod, state: mod.init(init_args)})

    spawn_link(__MODULE__, :loop, [server])
  end

  def cast(server, message) do
    send(server, {:cast, message})
    :ok
  end

  def call(server, message) do
    send(server, {:call, self(), message})

    receive do
      {:call_reply, value} ->
        {:ok, value}
    end
  end

  def loop(matcho(%{mod: mod, state: state})) do
    receive do
      {:cast, message} ->
        {:noreply, new_state} = mod.handle_cast(message, state)
        loop(buildo(%{mod: mod, state: new_state}))

      {:call, from, message} ->
        {:reply, value, new_state} = mod.handle_call(message, from, state)
        send(from, {:call_reply, value})
        loop(buildo(%{mod: mod, state: new_state}))
    end
  end
end

defmodule ObjServerTest do
  use ExUnit.Case, async: true

  defmodule Stack do
    use Objext, implements: [ObjServer]

    def init(_) do
      buildo([])
    end

    def handle_cast({:push, value}, matcho(stack)) do
      {:noreply, buildo([value | stack])}
    end

    def handle_call(:peek, _from, matcho([value | _]) = stack) do
      {:reply, value, stack}
    end
  end

  test "cast & call" do
    stack = ObjServer.start_link(Stack, [])

    assert :ok = ObjServer.cast(stack, {:push, 1})
    assert {:ok, 1} = ObjServer.call(stack, :peek)
  end
end
