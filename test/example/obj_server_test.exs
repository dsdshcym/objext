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

    spawn_link(fn -> loop(server) end)
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
    :ok
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:call_reply, value} ->
        {:ok, value}
    end
  end

  defp loop(server) do
    receive do
      {:cast, message} ->
        {:noreply, new_state} =
          server |> get_module() |> apply(:handle_cast, [message, get_state(server)])

        server |> put_state(new_state) |> loop()

      {:call, from, message} ->
        {:reply, value, new_state} =
          server
          |> get_module()
          |> apply(:handle_call, [message, from, get_state(server)])

        send(from, {:call_reply, value})

        server |> put_state(new_state) |> loop()
    end
  end

  defp get_module(matcho(%{mod: mod})), do: mod
  defp get_state(matcho(%{state: state})), do: state

  defp put_state(matcho(server_internal), new_state),
    do: buildo(%{server_internal | state: new_state})
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
