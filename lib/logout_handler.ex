defmodule LogoutHandler do
  @moduledoc """
    Handles AJAX-based logout requests
  """

  require EEx

  # helper function to render logged out session status  
  EEx.function_from_file :defp, :session, "priv/templates/session_logged_out.html.eex", []

  @doc """
    Initializes the logout handler
  """
  def init({ _any, :http }, req, state) do
    { :ok, req, state }
  end

  @doc """
    Removes the userid token from the session cookie
  """
  def handle(req, state) do
    {method, req} = :cowboy_req.method(req)
    req = :cowboy_req.set_resp_cookie(<<"userid">>, <<>>, [{:max_age, 0}], req)
    {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], session(), req
    {:ok, req, state}
  end

  @doc """ 
    Closes the logout handler
  """
  def terminate(_reason, _request, _state) do
    :ok
  end

end
