defmodule BetterstackLogger.TestUtils do
  def decode_logger_body(body) do
    body
    #|> :zlib.gunzip()
    |> Msgpax.unpack!()
  end
end
