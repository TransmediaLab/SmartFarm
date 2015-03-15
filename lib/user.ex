defmodule User do
  @moduledoc """
    Provides methods for creating and authenticating users
  """

  # Caution: Changing the secret will invalidate all passwords
  @secret <<"SOME SECRET THIS IS!">>

  @doc """
    Creates a new user with specified username and password 
    Returns a tuple {status, message} where status is either :ok or :fail
    Failure typically means the username is taken
  """
  def create(username, password, teacher) do
    if Database.username_available?(username) do
      salt = :crypto.rand_bytes(20) |> :base64.encode_to_string |> to_string
      crypted_password = :crypto.hash(:md5, password <> @secret <> salt) |> :base64.encode_to_string |> to_string
      if teacher do
        role = 1
      else
        role = 0
      end
IO.puts "User.create(#{username}, #{password}, #{teacher}) salt: #{salt}, crypted_password #{crypted_password}"
map = %{username: username, salt: salt, crypted_password: crypted_password, role: role}
IO.puts inspect map
      Database.user(nil, %{username: username, salt: salt, crypted_password: crypted_password, role: role})

      {:ok, <<"Logged in as ">> <> username}
    else
      {:fail, <<"Username ">> <> username <> <<" is already taken">>}
    end
  end

  @doc """
    Authenticates a user.  Returns {:ok, *id*, *message*, *username*} if successful, or {:fail, *message*}.
  """
  def authenticate(username, password) do
    username = username |> to_string
    password = password |> to_string
    if Database.username_available?(username) do 
      {:fail, :undefined, <<"Could not find that username and password combination.  Please try again.">>}
    else
      user = Database.user_with_username(username)
      test_password = :crypto.hash(:md5, password <> @secret <> user.salt) |> :base64.encode_to_string |> to_string
      if test_password == user.crypted_password do
        {:ok, user.id, <<"Logged in as ">> <> username}
      else
        {:fail, <<"Could not find that username and password combination.  Please try again.">>}
      end
    end
  end

  @doc """
    Returns the username of the user specified by *id*
  """
  def username(id) do
    user = Database.user(id)
    user.username
  end

end
