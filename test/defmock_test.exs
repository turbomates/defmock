defmodule DefmockTest do
  use ExUnit.Case
  doctest Defmock

  defmodule API do
    use Defmock

    defmock test_method: 1, test_method: 0, test_method: 3
  end


  setup_all do
    API.start_link
    :ok
  end

  setup do
    on_exit(fn -> API.clear end)
  end

  test "method_name in atom without arity" do
    API.mock(:test_method, {:ok, %{}})
    {:ok, %{}} = API.test_method
  end

  test "method_name in list without arity" do
    API.mock([test_method: 0], {:ok, %{}})
    {:ok, %{}} = API.test_method
  end

  test "method_name in list with 1 arity" do
    API.mock([test_method: 1], fn([first_v: :test]) -> {:ok, %{}} end)
    {:ok, %{}} = API.test_method([first_v: :test])
  end

  test "list method_names" do
    API.mock([test_method: 0, test_method: 3], {:ok, %{}})
    API.mock([test_method: 1], fn(m) -> {:ok, %{value: m}} end)
    {:ok, %{value: :first_v}} = API.test_method(:first_v)
    {:ok, %{}} = API.test_method
  end

  test "mock is not set" do
    {:error, {:mock_error, _}} = API.test_method
  end
end
