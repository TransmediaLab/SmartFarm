defmodule LoginHandler do

  require EEx

  EEx.function_from_file :defp, :login, "priv/templates/login.html.eex", []

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
        {status, message} = User.authenticate(username, password)
        if status == :ok do
          {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], message, req
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