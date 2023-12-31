defmodule BetterstackLogger.IntegrationTest do
  @moduledoc false
  use ExUnit.Case
  alias BetterstackLogger.{HttpBackend, TestUtils}
  require Logger

  @path BetterstackApiClient.api_path()

  @logger_backend HttpBackend
  @source "source2354551"

  setup do
    bypass = Bypass.open()
    Application.put_env(:betterstack_logger_backend, :url, "http://127.0.0.1:#{bypass.port}")
    Application.put_env(:betterstack_logger_backend, :source_id, @source)
    Application.put_env(:betterstack_logger_backend, :level, :info)
    Application.put_env(:betterstack_logger_backend, :flush_interval, 500)
    Application.put_env(:betterstack_logger_backend, :max_batch_size, 100)

    Logger.add_backend(@logger_backend)

    on_exit(fn ->
      BetterstackLogger.context(test_context: nil)
      Logger.remove_backend(@logger_backend, flush: true)
    end)

    {:ok, bypass: bypass}
  end

  test "logger backend sends a POST request", %{bypass: bypass} do
    :ok = Logger.configure_backend(@logger_backend, metadata: [])
    log_msg = "Incoming log from test"
    BetterstackLogger.context(test_context: %{some_metric: 1337})

    Bypass.expect(bypass, "POST", @path, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      assert {"authorization", "Bearer #{@source}"} in conn.req_headers

      body = TestUtils.decode_logger_body(body)

      assert [
        %{
          "message" => "Incoming log from test " <> _,
          "metadata" => %{
            "level" => level,
            "context" => %{"pid" => _},
            "test_context" => %{"some_metric" => 1337}
          },
          "timestamp" => _
        }
        | _
      ] = body

      assert level in ["info", "error"]

      Plug.Conn.resp(conn, 200, "")
    end)

    for n <- 1..10, do: Logger.info(log_msg <> " ##{n}")

    Process.sleep(1_000)

    for n <- 1..10, do: Logger.error(log_msg <> " ##{20 + n}")

    Process.sleep(1_000)

    for n <- 1..10, do: Logger.debug(log_msg <> " ##{30 + n}")

    Process.sleep(1_000)
  end

  test "doesn't POST log events with a lower level", %{bypass: _bypass} do
    log_msg = "Incoming log from test"

    :ok = Logger.debug(log_msg)
  end

  @msg "Incoming log from test with all metadata"
  test "correctly handles metadata keys", %{bypass: bypass} do
    :ok = Logger.configure_backend(@logger_backend, metadata: :all)
    BetterstackLogger.context(test_context: %{some_metric: 7331})

    Bypass.expect_once(bypass, "POST", @path, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      body = TestUtils.decode_logger_body(body)

      assert [
                 %{
                   "message" => @msg,
                   "metadata" => %{
                     "level" => "info",
                     "context" => %{
                       "pid" => pidbinary,
                       "module" => _,
                       "file" => _,
                       "line" => _,
                       "function" => _
                     },
                     "test_context" => _
                   },
                   "timestamp" => _
                 }
                 | _
               ] = body

      Plug.Conn.resp(conn, 200, "")
    end)

    log_msg = @msg

    for _n <- 1..45, do: Logger.info(log_msg)

    Process.sleep(1_000)
  end
end
