defmodule BetterstackLoggerTest do
  @moduledoc false
  alias BetterstackLogger.HttpBackend
  use ExUnit.Case
  import BetterstackLogger
  doctest BetterstackLogger
  use Placebo
  require Logger

  @logger_backend HttpBackend
  @source "source2354551"

  setup_all do
    Application.put_env(:betterstack_logger_backend, :url, "http://127.0.0.1:4000")
    Application.put_env(:betterstack_logger_backend, :source_id, @source)
    Application.put_env(:betterstack_logger_backend, :level, :info)
    Application.put_env(:betterstack_logger_backend, :flush_interval, 100)
    Application.put_env(:betterstack_logger_backend, :max_batch_size, 2)

    case Logger.add_backend(@logger_backend) do
      {:ok, _pid} -> :noop
      {:error, :already_present} -> :noop
      {:error, err} -> throw(err)
    end

    on_exit(&BetterstackLogger.reset_context/0)
    :ok
  end

  describe "debug, info, warn, error functions" do
    test "uses same configuration as Logger functions" do
      allow(BetterstackApiClient.new(any()), return: %Tesla.Client{})

      allow(BetterstackApiClient.post_logs(any(), any()),
        return: {:ok, %Tesla.Env{status: 200}}
      )

      BetterstackLogger.context(%{context_key: [:context_value, 1, "string"]})
      Logger.bare_log(:info, "msg", data: %{a: 1})
      BetterstackLogger.info("msg", data: %{a: 1})

      Process.sleep(200)

      assert_called(
        BetterstackApiClient.post_logs(
          any(),
          is(fn [logger, betterstack_logger] ->
            assert Map.drop(logger["metadata"]["context"], ~w[domain gl time]) ==
                     Map.drop(betterstack_logger["metadata"]["context"], ~w[domain gl time])

            assert Map.drop(logger["metadata"], ~w[context]) ==
                     Map.drop(betterstack_logger["metadata"], ~w[context])

            assert Map.drop(logger, ~w[metadata timestamp]) ==
                     Map.drop(betterstack_logger, ~w[metadata timestamp])
          end)
        )
      )
    end
  end

  describe "Context" do
    test "gets, sets and unsets one context key" do
      assert context() == %{}

      assert context(advanced_logging: true) == %{advanced_logging: true}
      assert context(advanced_logging: false) == %{advanced_logging: false}

      assert context(simple_logging: true) == %{
               simple_logging: true,
               advanced_logging: false
             }

      assert context() == %{simple_logging: true, advanced_logging: false}

      context(simple_logging: nil)
      context(advanced_logging: nil)
      assert context() == %{}
    end

    test "gets, sets and unsets multiple context keys" do
      assert context() == %{}

      assert context(key1: 1, key2: 2) == %{key1: 1, key2: 2}
      assert context(key2: 3, key4: 4) == %{key1: 1, key2: 3, key4: 4}
      assert context() == %{key1: 1, key2: 3, key4: 4}

      reset_context()
      assert context() == %{}
    end

    test "set context raises for invalid values" do
      assert_raise FunctionClauseError, fn ->
        context(11.11)
      end

      assert_raise FunctionClauseError, fn ->
        context("false")
      end

      assert_raise FunctionClauseError, fn ->
        context(1_000)
      end
    end
  end
end
