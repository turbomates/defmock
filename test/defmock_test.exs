defmodule DefmockTest do
  use ExUnit.Case
  use Defmock
  doctest Defmock
  defmock test_method: 1, test_method: 0, test_method: 3

  setup_all do
    start_link
    :ok
  end

  setup do
    on_exit fn ->
      clear
    end
    :ok
  end

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "method_name in atom without arity" do
    mock(:test_method, {:ok, %{}})
    {:ok, %{}} = test_method
  end

  test "method_name in list without arity" do
    mock([test_method: 0], {:ok, %{}})
    {:ok, %{}} = test_method
  end

  test "method_name in list with 1 arity" do
    mock([test_method: 1], fn([first_v: :test]) -> {:ok, %{}} end)
    {:ok, %{}} = test_method([first_v: :test])
  end

  test "list method_names" do
    mock([test_method: 0, test_method: 3], {:ok, %{}})
    mock([test_method: 1], fn(m) -> {:ok, %{value: m}} end)
    {:ok, %{value: :first_v}} = test_method(:first_v)
    {:ok, %{}} = test_method()
  end
end
