defmodule Objext.Mock do
  defmacro defmock(for: interface) do
    interface = Macro.expand(interface, __CALLER__)

    cond do
      Objext.Interface.is_interface(interface) ->
        protocol = Module.concat(interface, Protocol)

        quote do
          require Promox
          Promox.defmock(for: unquote(protocol))
        end

      Objext.Interface.is_protocol(interface) ->
        quote do
          require Promox
          Promox.defmock(for: unquote(interface))
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
