defmodule Mix.Tasks.BetterstackLogger.VerifyConfig do
  alias BetterstackLogger.CLI
  use Mix.Task

  @app :betterstack_logger_backend
  @default_api_url "https://in.logs.betterstack.com"

  @impl Mix.Task
  def run(_args \\ []) do
    IO.puts("You are verifying config for the #{Mix.env()} environment")
    {:ok, _} = Application.ensure_all_started(:betterstack_logger_backend)

    source_id = get_env(:source_id) || System.get_env("BETTERSTACK_SOURCE_ID")
    url = get_env(:url) || System.get_env("BETTERSTACK_URL") || @default_api_url

    CLI.throw_on_missing_source!(source_id)
    CLI.throw_on_missing_url!(url)

    client = BetterstackApiClient.new(%{source_id: source_id, url: url})

    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601() |> Kernel.<>("Z")

    result =
      BetterstackApiClient.post_logs(
        client,
        [
          %{
            "message" => "BetterstackLogger has been properly setup",
            "metadata" => %{},
            "level" => "info",
            "timestamp" => timestamp
          }
        ]
      )

    case result do
      {:ok, %{status: status}} when status in 200..299 ->
        IO.puts("Betterstack API endpoint responded ok, check your dashboard!")

      {:ok, %{status: status, body: body}} ->
        IO.puts("HTTP request to Betterstack API endpoint returned an HTTP status code #{status}.")
        IO.puts("Response body is: #{body}")

      {:error, tesla_env} ->
        IO.puts("Unknown Error")
        IO.inspect(tesla_env)
    end
  end

  def get_env(key) do
    Application.get_env(@app, key)
  end
end
