defmodule Defmock do
  defmacro __using__(_) do
    quote do
      require Defmock
      import Defmock

      def start_mock do
        Agent.start_link(fn -> Map.new end, name: __MODULE__)
      end

      def clear_mock do
        Agent.update(__MODULE__, fn(_) -> Map.new end)
      end

      def stop do
        Agent.stop(__MODULE__)
      end

      def mock([]) do
        :ok
      end

      def mock([]), do: :ok

      def mock([{method_name, fun} | t]) do
        mock(method_name, fun)
        mock(t)
      end

      def mock(method_name, fun) when is_atom(method_name) and is_function(fun) do
        {:arity, arity} = :erlang.fun_info(fun, :arity)
        Agent.update(__MODULE__, fn(map) -> Map.put(map, [method_name, arity], fun) end)
      end

      def call_mock(method_name, args \\ []) do
        Agent.get(__MODULE__, fn(map) ->
          key = [method_name, length(args)]
          if Map.has_key?(map, key) do
            {:ok, Map.fetch!(map, key)}
          else
            {:error, :undefined}
          end
        end) |> call_mock_value(args)
      end

      defp call_mock_value({:error, :undefined} = e, _), do: e
      defp call_mock_value({:ok, f}, args) when is_function(f) and is_list(args), do: apply(f, args)
    end
  end

  defmacro defmock(args) do
    Enum.map(args, fn({fun_name, arity}) ->
      arg_str = if arity > 0, do: Enum.map(1..arity, &("v#{&1}")) |> Enum.join(","), else: ""
      quote do
        def unquote(fun_name)(fun_arguments) do
          call_mock(unquote(fun_name), [fun_arguments])
        end
      end
      |> Macro.to_string
      |> String.replace("fun_arguments", arg_str)
      |> Code.string_to_quoted!
    end)
  end
end
