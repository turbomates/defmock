defmodule DefmockTest do
  use ExUnit.Case
  doctest Defmock

  defmodule API do
    use Defmock

    defmock test_method: 0, test_method: 1, test_method: 2
  end


  setup_all do
    API.start_mock
    :ok
  end

  setup do
    on_exit(fn -> API.clear_mock end)
  end

  test "mock single method" do
    API.mock(test_method: fn -> :fn end)
    assert API.test_method == :fn
  end

  test "mock multiple methods" do
    API.mock(test_method: fn -> :fn0 end, test_method: fn(_) -> :fn1 end)
    assert API.test_method == :fn0
    assert API.test_method(1) == :fn1
  end

  test "mock is not set" do
    {:error, :undefined} = API.test_method
  end
end
