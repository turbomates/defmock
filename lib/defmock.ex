defmodule Defmock do
  defmacro __using__(_) do
    quote do
      require Defmock
      import Defmock

      def start_link do
        Agent.start_link(fn -> Map.new end, name: __MODULE__)
      end

      def clear do
        Agent.update(__MODULE__, fn(_) -> Map.new end)
      end

      def stop do
        Agent.stop(__MODULE__)
      end

      def mock(method_names, value) when is_list(method_names) do
        Enum.each(method_names, fn({method_name, arity}) ->
          mock(method_name, value, arity)
        end)
      end

      def mock(method_name, value, arity \\ 0) when is_atom(method_name) do
        Agent.update(__MODULE__, fn(map) -> Map.put(map, :"#{method_name}/#{arity}", value) end)
      end

      def call_mock(method_name, args \\ []) do
        Agent.get(__MODULE__, fn(map) -> Map.fetch!(map, :"#{method_name}/#{length(args)}") end) |> call_mock_value(args)
      end

      defp call_mock_value(f, args) when is_function(f) and is_list(args) do
        apply(f, args)
      end

      defp call_mock_value(v, _) do
        v
      end
    end
  end

  defmacro defmock(args) do
    Enum.map(args, fn({fun_name, arity}) ->
      arg_str = if arity > 0, do: Enum.map(1..arity, &("v#{&1}")) |> Enum.join(","), else: ""
      quote do
        def unquote(fun_name)(variebles) do
          call_mock(unquote(fun_name), [variebles])
        end
      end
      |> Macro.to_string
      |> String.replace("variebles", arg_str)
      |> Code.string_to_quoted!
    end)
  end
end
