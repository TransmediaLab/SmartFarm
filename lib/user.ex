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
    case check_for_username(username) do
      :exists ->
        {:fail, <<"Username ">> <> username <> <<" is already taken">>}
      :unknown ->
        salt = :crypto.rand_bytes(20) |> :base64.encode_to_string |> to_string
        crypted_password = :crypto.hash(:md5, password <> @secret <> salt) |> :base64.encode_to_string |> to_string
        IO.puts to_string "INSERT INTO users (username, crypted_password, salt) VALUES ('" <> username <> "','" <> crypted_password <> "','" <> salt <>"')"
        Postgrex.Connection.query!(:conn, "INSERT INTO users (username, crypted_password, salt, teacher) VALUES ('" <> username <> "','" <> crypted_password <> "','" <> salt <>"'," <> teacher <> ")", [])
        {:ok, <<"User ">> <> username <> <<" created">>}
    end
  end

  @doc """
  Authenticates a user
  """
  def authenticate(username, password) do
    username = username |> to_string
    password = password |> to_string
    result = Postgrex.Connection.query!(:conn, "SELECT id, crypted_password, salt FROM users WHERE username='" <> username <> "'", [])
    if result.num_rows == 0 do
      {:fail, <<"Could not find that username and password combination.  Please try again.">>}
    else
      [{_id, crypted_password, salt} | _tail] = result.rows
      test_password = :crypto.hash(:md5, password <> @secret <> salt) |> :base64.encode_to_string |> to_string
      if test_password == crypted_password do
        {:ok, <<"Logged in as ">> <> username}
      else
        {:fail, <<"Could not find that username and password combination.  Please try again.">>}
      end
    end
  end

  @doc """
  Checks to see if the supplied username is taken.
  Returns :exists or :unknown
  """  
  defp check_for_username(username) do
    result = Postgrex.Connection.query!(:conn, "SELECT id FROM users WHERE username='" <> username <> "'", [])
    if result.num_rows == 0 do
      :unknown
    else
      :exists
    end
  end

end
