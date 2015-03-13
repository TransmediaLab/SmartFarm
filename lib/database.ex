defmodule Database do

  require Record
  
  @rows_to_list 2

  def init do
    {:ok, pid} = Postgrex.Connection.start_link(hostname: "localhost", username: "smartfarm", password: "smartFARMING", database: "smartfarm_#{Mix.env}")
    Process.register(pid, :conn)
  end

  @doc """
    Checks to see if *username* already exists in the database
  """
  def username_available?(username) do
    result = Postgrex.Connection.query!(:conn, "SELECT id FROM users WHERE username='#{esc(username)}'", [])
    if result.num_rows == 0 do
      true
    else
      false
    end
  end

  @doc """
    Returns a map of the properties for the user with the supplied *username*
  """
  def user_with_username(username) do
    %Postgrex.Result{num_rows: 1, rows: [{id, username, crypted_password, salt, role}]} = Postgrex.Connection.query!(:conn, "SELECT id, username, crypted_password, salt, role FROM users WHERE username = '#{esc(username)}';", [])
    %{id: id, username: username, crypted_password: crypted_password, salt: salt, role: role}
  end

  @doc """
    Lists the users currently in the database
  """
  def list_users(last_id \\ 0) do
    %Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT id, username FROM users;", [])
    rows
  end

  @doc """
    Returns a map of the properties for the user specified by *id*
  """
  def user(id) do
    %Postgrex.Result{num_rows: 1, rows: [{username, crypted_password, salt, role}]} = Postgrex.Connection.query!(:conn, "SELECT username, crypted_password, salt, role FROM users WHERE id = #{id};", [])
    %{username: username, crypted_password: crypted_password, salt: salt, role: role}
  end

  @doc """
    Creates a new user populated with the properties in *data*
  """
  def user(nil, data)do
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "INSERT INTO users (username, crypted_password, salt, role) VALUES ('#{esc(data.username)}', '#{data.crypted_password}', '#{data.salt}', #{data.role});", [])
    %Postgrex.Result{rows: [{id}]} = Postgrex.Connection.query!(:conn, "SELECT currval(pg_get_serial_sequence('users', 'id'));", [])
    id  
  end


  @doc """
    Lists the plant models currently in the database
  """
  def list_plants(last_id \\ 0) do
    %Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT plants.id, plants.user_id, users.username, plants.name, plants.description FROM plants, users WHERE users.id = plants.user_id AND plants.id > #{last_id} ORDER BY plants.id LIMIT #{@rows_to_list};", [])
    rows
  end

  @doc """ 
    Lists the plant models currently found in the database that satisfy the properties in *query*
  """
  def list_plants(query, last_id) do
    where = " AND plants.id > #{last_id} "
    
    if List.keymember?(query, "user_id", 0) do
      where = where <> " AND (#{ user_id_snippet(query) })"
    end

    search = List.keyfind(query, "search", 0)
    if search do
      {"search", terms} = search
      where = where <> "AND plants.search @@ plainto_tsquery('#{terms}') "
    end

    %Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT plants.id, plants.user_id, users.username, plants.name, plants.description FROM plants, users WHERE users.id = plants.user_id #{where} ORDER BY plants.id LIMIT #{@rows_to_list};", [])
    rows
  end

  @doc """
    Returns a Map containing the properties of the plant model specified
    by *id* loaded from the database
  """
  def plant(id) when is_integer(id) or is_binary(id) do
    %Postgrex.Result{num_rows: 1, rows: [{id, user_id, name, description, code, workspace}]} = Postgrex.Connection.query!(:conn, "SELECT id, user_id, name, description, code, workspace FROM plants WHERE id = " <> to_string(id), [])
    %{id: id, user_id: user_id, name: name, description: description, code: code, workspace: workspace}
  end

  @doc """
    Creates a new plant model in the database with properties matching those supplied in
    the Map *data*
  """
  def plant(nil, data) do
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "INSERT INTO plants (user_id, name, description, code, workspace) VALUES (#{data.user_id}, '#{esc(data.name)}', '#{esc(data.description)}', '#{data.code}', '#{esc(data.workspace)}');", [])
    %Postgrex.Result{rows: [{id}]} = Postgrex.Connection.query!(:conn, "SELECT currval(pg_get_serial_sequence('plants', 'id'));", [])
    id
  end

  @doc """
    Updates the database entry for the plant model specified by *id* with
    the values contained in the Map *data*.  Returns the plant model's id.
  """
  def plant(id, data) do 
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "UPDATE plants SET name='#{esc(data.name)}', description='#{esc(data.description)}', code='#{esc(data.code)}', workspace='#{esc(data.workspace)}' WHERE id = #{id};", [])
    id
  end


  @doc """
    Lists the weather currently in the database
  """
  def list_weather(last_id \\ 0) do
    %Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT weather.id, weather.user_id, users.username, weather.name, weather.description FROM weather, users WHERE users.id = weather.user_id AND weather.id > #{last_id} ORDER BY weather.id LIMIT #{@rows_to_list};", [])
    rows
  end

  @doc """ 
    Lists the weather currently found in the database that satisfy the properties in *query*
  """
  def list_weather(query, last_id) do
    where = " AND weather.id > #{last_id} "
    
    if List.keymember?(query, "user_id", 0) do
      where = where <> " AND (#{ user_id_snippet(query) })"
    end

    search = List.keyfind(query, "search", 0)
    if search do
      {"search", terms} = search
      where = where <> "AND weather.search @@ plainto_tsquery('#{terms}') "
    end

    %Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT weather.id, weather.user_id, users.username, weather.name, weather.description FROM weather, users WHERE users.id = weather.user_id #{where} ORDER BY weather.id LIMIT #{@rows_to_list};", [])
    rows
  end

  @doc """
    Returns a Map containing the properties of the weather model specified
    by *id* loaded from the database
  """
  def weather(id) when is_integer(id) or is_binary(id) do
    %Postgrex.Result{num_rows: 1, rows: [{id, user_id, name, description, code, workspace}]} = Postgrex.Connection.query!(:conn, "SELECT id, user_id, name, description, code, workspace FROM weather WHERE id = " <> to_string(id), [])
    %{id: id, user_id: user_id, name: name, description: description, code: code, workspace: workspace}
  end

  @doc """
    Creates a new weather model in the database with properties matching those supplied in
    the Map *data*
  """
  def weather(nil, data) do
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "INSERT INTO weather (user_id, name, description, code, workspace) VALUES (#{data.user_id}, '#{esc(data.name)}', '#{esc(data.description)}', '#{data.code}', '#{esc(data.workspace)}');", [])
    %Postgrex.Result{rows: [{id}]} = Postgrex.Connection.query!(:conn, "SELECT currval(pg_get_serial_sequence('weather', 'id'));", [])
    id
  end

  @doc """
    Updates the database entry for the weather specified by *id* with
    the values contained in the Map *data*.  Returns the weather's id.
  """
  def weather(id, data) do 
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "UPDATE weather SET name='#{esc(data.name)}', description='#{esc(data.description)}', code='#{esc(data.code)}', workspace='#{esc(data.workspace)}' WHERE id = #{id};", [])
    id
  end

  @doc """
    Lists the farms currently found in the database
  """
  def list_farms(last_id \\ 0) when is_integer(last_id) or is_binary(last_id) do
    %Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT farms.id, farms.user_id, users.username, farms.name, farms.description FROM farms, users WHERE users.id = farms.user_id AND farms.id > #{last_id} ORDER BY farms.id LIMIT #{@rows_to_list};", [])
    rows
  end

  @doc """ 
    Lists the farms currently found in the database that satisfy the properties in *query*
  """
  def list_farms(query, last_id) do
    where = " AND farms.id > #{last_id} "
    
    if List.keymember?(query, "user_id", 0) do
      where = where <> " AND (#{ user_id_snippet(query) })"
    end

    search = List.keyfind(query, "search", 0)
    if search do
      {"search", terms} = search
      where = where <> "AND farms.search @@ plainto_tsquery('#{terms}') "
    end

    %Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT farms.id, farms.user_id, users.username, farms.name, farms.description FROM farms, users WHERE users.id = farms.user_id #{where} ORDER BY farms.id LIMIT #{@rows_to_list};", [])
    rows
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
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "INSERT INTO farms (user_id, name, description, latitude, longitude, fields) VALUES (#{data.user_id}, '#{esc(data.name)}', '#{esc(data.description)}', '#{data.latitude}', '#{data.longitude}', '#{esc(data.fields)}');", [])
    %Postgrex.Result{rows: [{id}]} = Postgrex.Connection.query!(:conn, "SELECT currval(pg_get_serial_sequence('farms', 'id'));",[])
    id
  end

  @doc """
    Updates the database entry for the farm specified by *id* with the 
    values contained in the Map *data*.  Returns the farm's id.
  """
  def farm(id, data) do
    Postgrex.Connection.query!(:conn, "UPDATE farms SET name='#{esc(data.name)}', description='#{esc(data.description)}', latitude=#{data.latitude}, longitude=#{data.longitude}, fields='#{esc(data.fields)}' WHERE id = " <> to_string(id), [])
    id
  end

  # Generate a user_id snippet from a query string
  defp user_id_snippet(query) do
    query 
      |> extract("user_id", [])
      |> Enum.map(fn uid -> "user_id=#{uid}" end)
      |> Enum.join(" OR ")
  end

  # Extract and return as a list all values with a key from a list
  defp extract([], key, values) do
    values
  end

  defp extract([{key, value}|tail], key, values) do
    extract(tail, key, [value|values])
  end

  defp extract([_|tail], key, values) do
    extract(tail, key, values)
  end


  # Escape strings
  defp esc(text) do
    text
      |> String.replace("'", "''") 
  end

end

