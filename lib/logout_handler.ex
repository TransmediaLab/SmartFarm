defmodule LogoutHandler do

  require EEx
  
  EEx.function_from_file :defp, :session, "priv/templates/session_logged_out.html.eex", []

  def init({ _any, :http }, req, state) do
    { :ok, req, state }
  end

  def handle(req, state) do
    {method, req} = :cowboy_req.method(req)
    req = :cowboy_req.set_resp_cookie(<<"userid">>, <<>>, [{:max_age, 0}], req)
    {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], session(), req
    {:ok, req, state}
  end

  def terminate(_reason, _request, _state) do
    :ok
  end

end
