defmodule KOTL.Monitor.Check.Website do
  def check_site(location) do
    request_uri = String.to_char_list(location)
    request = :httpc.request(:get, {request_uri, []}, [], [])

    case request do
      {:ok, resp} ->
        {{_, response_code, _}, _headers, body} = resp
        response_code
      {:error, _} ->
        :error
    end
  end
end
