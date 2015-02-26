defmodule Database do

  def init do
    {:ok, pid} = Postgrex.Connection.start_link(hostname: "localhost", username: "smartfarm", password: "smartFARMING", database: "smartfarm")
    Process.register(pid, :conn)
  end

  def check_for_username(username) do
    result = Postgrex.Connection.query!(:conn, "SELECT id FROM users WHERE username='" <> username <> "'", [])
    if result.num_rows == 0 do
      :unknown
    else
      :exists
    end
  end

  def create_user(username, crypted_password) do
  end

  def list_weather_models do
    result = Postgrex.Connection.query!(:conn, "SELECT id, name, description FROM weather_model", [])
    result.rows
  end

  def weather_model(id) do
    result = Postgrex.Connection.query!(:conn, "SELECT id, code, workspace FROM weather_model WHERE id = " <> to_string(id), [])
    [head | _tail]  = result.rows
    head
  end

  def update_weather_model(id, workspace) do
    Postgrex.Connection.query!(:conn, "UPDATE weather_model SET workspace='" <> workspace <> "' WHERE id = " <> to_string(id), [])
  end

end
