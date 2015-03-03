defmodule LoginHandler do

  require EEx

  EEx.function_from_file :defp, :login, "priv/templates/login.html.eex", []
  EEx.function_from_file :defp, :session, "priv/templates/session_logged_in.html.eex", [:id, :username]

  def init({ _any, :http }, req, state) do
    { :ok, req, state }
  end

  def handle(req, state) do
    {method, req} = :cowboy_req.method(req)

    case method do
      "GET" ->
        head = Layout.head("Sign In", [])
        nav = Layout.nav(:auth)
        content = login()
        {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(head, nav, content), req
      "POST" ->
        {:ok, fields, req} = :cowboy_req.body_qs(req)
        {"username", username} = List.keyfind fields, "username", 0
        {"password", password} = List.keyfind fields, "password", 0
        {status, user_id, message} = User.authenticate(username, password)
IO.puts "AUTHENTICATED AS #{user_id}"
        if status == :ok do
          req = :cowboy_req.set_resp_cookie(<<"userid">>, to_string(user_id), [], req)
          {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], session(user_id, username), req
        else
          {:ok, req} = :cowboy_req.reply 403, [{"Content-Type", "text/html"}], Layout.alert(<<"danger">>, message), req
        end
    end  
    {:ok, req, state}
  end

  def terminate(_reason, _request, _state) do
    :ok
  end

end
