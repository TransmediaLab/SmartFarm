defmodule Database do

  require Record
  
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



  @doc """
    Returns a Map containing the properties of the farm specified by *id*
    loaded from the database
  """
  def farm(id) when is_integer(id) or is_binary(id) do
    %Postgrex.Result{num_rows: 1, rows: [{id, user_id, name, description, latitude, longitude, fields}]} = Postgrex.Connection.query!(:conn, "SELECT id, user_id, name, description, latitude, longitude, fields FROM farms WHERE id = " <> to_string(id), [])
    %{id: id, user_id: user_id, name: name, description: description, latitude: latitude, longitude: longitude, fields: fields}
  end

  @doc """
    Creates a new entry in the database with properties matching those supplied in the Map *data*.  
    Returns the newly-created farm's id.
  """
  def farm(nil, data) do
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "INSERT INTO farms (user_id, name, description, latitude, longitude, fields) VALUES (#{data.user_id}, '#{h(data.name)}', '#{h(data.description)}', '#{data.latitude}', '#{data.longitude}', '#{h(data.fields)}');", [])
    %Postgrex.Result{rows: [{id}]} = Postgrex.Connection.query!(:conn, " SELECT currval(pg_get_serial_sequence('farms', 'id'));",[])
    id
  end

  @doc """
    Updates the database entry for the farm specified by *id* with the 
    values contained in the Map *data*.  Returns the farm's id.
  """
  def farm(id, data) do
    Postgrex.Connection.query!(:conn, "UPDATE farms SET name='#{h(data.name)}', description='#{h(data.description)}', latitude=#{data.latitude}, longitude=#{data.longitude}, fields='#{h(data.fields)}' WHERE id = " <> to_string(id), [])
    id
  end

  # Escape strings
  defp h(text) do
    String.replace(text, "'", "''")
  end

end
