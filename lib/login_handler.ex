defmodule LoginHandler do
  @moduledoc """
    Handles AJAX-based login requests
  """

  require EEx

  # helper function to render logged in session status
  EEx.function_from_file :defp, :session, "priv/templates/session_logged_in.html.eex", [:id, :username]

  @doc """ 
    Initializes the LoginHandler
  """
  def init({ _any, :http }, req, state) do
    { :ok, req, state }
  end

  @doc """
    Authenticates login requests and sets the userid cookie if successful
  """
  def handle(req, state) do
    {:ok, fields, req} = :cowboy_req.body_qs(req)
    {"username", username} = List.keyfind fields, "username", 0
    {"password", password} = List.keyfind fields, "password", 0
    {status, user_id, message} = User.authenticate(username, password)
    if status == :ok do
      req = :cowboy_req.set_resp_cookie(<<"userid">>, to_string(user_id), [], req)
      {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], session(user_id, username), req
    else
      {:ok, req} = :cowboy_req.reply 403, [{"Content-Type", "text/html"}], Layout.alert(<<"danger">>, message), req
    end
    {:ok, req, state}
  end

  @doc """
    Closes the LoginHandler
  """
  def terminate(_reason, _request, _state) do
    :ok
  end

end
