defmodule Objext.Mock do
  defmacro defmock(for: interface) do
    quote do
      require unquote(interface)
      require Promox

      cond do
        Objext.Interface.is_interface(unquote(interface)) ->
          protocol = Module.concat(unquote(interface), Protocol)
          Promox.defmock(for: protocol)

        Objext.Interface.is_protocol(unquote(interface)) ->
          Promox.defmock(for: unquote(interface))

        true ->
          raise ArgumentError,
                "defmock failed: #{inspect(unquote(interface))} is not an Objext interface nor a Protocol module"
      end
    end
  end

  def new() do
    Promox.new()
  end

  def stub(mock, interface, name, code) do
    cond do
      Objext.Interface.is_interface(interface) ->
        protocol = Module.concat(interface, Protocol)
        Promox.stub(mock, protocol, name, code)

      Objext.Interface.is_protocol(interface) ->
        Promox.stub(mock, interface, name, code)
    end
  end

  def expect(mock, interface, name, n \\ 1, code) do
    cond do
      Objext.Interface.is_interface(interface) ->
        protocol = Module.concat(interface, Protocol)
        Promox.expect(mock, protocol, name, n, code)

      Objext.Interface.is_protocol(interface) ->
        Promox.expect(mock, interface, name, n, code)
    end
  end

  # TODO: do not mention *.Protocol in VerificationError message
  def verify!(mock), do: Promox.verify!(mock)
end
