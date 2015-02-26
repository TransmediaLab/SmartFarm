defmodule LogoutHandler do

  def init({ _any, :http }, req, state) do
    { :ok, req, state }
  end

  def handle(req, state) do
    {method, req} = :cowboy_req.method(req)
    req = :cowboy_req.set_resp_cookie(<<"sessionid">>, <<>>, [{:max_age, 0}], req)
    {:ok, req} = :cowboy_req.reply 302, [{"Location", "/"}], <<"Redirecting">>, req
    {:ok, req, state}
  end

  def terminate(_reason, _request, _state) do
    :ok
  end

end
