defmodule SignupHandler do
  @moduledoc """
    Handles AJAX-based account creation
  """

  require EEx

  # helper function to render logged in session status
  EEx.function_from_file :defp, :session, "priv/templates/sessions/logged_in.html.eex", [:id, :username]

  @doc """
    Initializes the handler
  """
  def init({ _any, :http }, req, state) do
    { :ok, req, state }
  end

  @doc """
    Handles account creation requests 
  """
  def handle(req, state) do
    {:ok, fields, req} = :cowboy_req.body_qs(req)
    {"username", username} = List.keyfind fields, "username", 0
    {"password", password} = List.keyfind fields, "password", 0
    {"password_confirmation", password_confirmation} = List.keyfind fields, "password_confirmation", 0
    {"teacher", teacher} = List.keyfind fields, "teacher", 0
    if password != password_confirmation do
      {:ok, req} = :cowboy_req.reply 403, [{"Content-Type", "text/html"}], Layout.alert(<<"danger">>, <<"Password fields must match">>), req
    else
IO.puts "Creating user with #{username}, #{password}, #{teacher}"
      {status, message} = User.create(username, password, teacher)
IO.puts "Tried to create user, with result: #{status}, #{message}"
      if status == :ok do
IO.puts "Looking up user by username #{username}"
        user = Database.user_with_username(username)
IO.puts inspect user
        response = %{user_id: user.id, token: "FOOBAR", username: username, html: session(user.id, username)}
          |> Poison.encode!
          |> to_string
IO.puts "Responding with: #{response}"
        {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/json"}], response, req
      else
IO.puts "Problem"
        {:ok, req} = :cowboy_req.reply 403, [{"Content-Type", "text/html"}], Layout.alert(<<"danger">>, message), req
      end
    end
    {:ok, req, state}
  end

  @doc """
    Closes the handler
  """
  def terminate(_reason, _request, _state) do
    :ok
  end

end
