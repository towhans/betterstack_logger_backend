defmodule BetterstackLogger.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      BetterstackLogger.Repo
    ]

    opts = [strategy: :one_for_one, name: BetterstackLogger.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
