defmodule BetterstackLogger.Repo do
  use Ecto.Repo, otp_app: :betterstack_logger_backend, adapter: Etso.Adapter
end
