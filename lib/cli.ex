defmodule BetterstackLogger.CLI do
  def throw_on_missing_url!(url) do
    unless url do
      throw("Betterstack API url #{not_configured()}")
    end
  end

  def throw_on_missing_source!(source_id) do
    unless source_id do
      throw("Betterstack source_id #{not_configured()}")
    end
  end

  def throw_on_missing_api_key!(api_key) do
    unless api_key do
      throw("Betterstack API key #{not_configured()}")
    end
  end

  def not_configured() do
    "for BetterstackLogger backend is NOT configured"
  end
end
