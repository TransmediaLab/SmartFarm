defmodule WeatherHandler do
  @moduledoc """
    Handles weather-related http requests
  """

  require EEx
  require Weather

  # HTML page template functions
  EEx.function_from_file :defp, :weather_index, "priv/templates/weather/index.html.eex", [:models]
  EEx.function_from_file :defp, :weather_edit,  "priv/templates/weather/edit.html.eex",  []
  EEx.function_from_file :defp, :weather_model, "priv/templates/weather/model.html.eex", [:id, :user_id, :username, :name, :description]

  @doc """
    Initializes the http handler
  """
  def init({ _any, :http }, req, []) do
    { :ok, req, :undefined }
  end

  @doc """
    handles page requests
  """
  def handle(req, state) do
    {user_id, req} = :cowboy_req.cookie(<<"userid">>, req, nil)
    {id, req} = :cowboy_req.binding(:id, req, :all)
    case id do 
      :all ->         
         #%Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT id, name, description FROM weather;", [])
         content = Database.list_weather
         |> Enum.map(fn {id, user_id, username, name, desc} -> weather_model(id, user_id, username, name, desc) end)
         |> weather_index
         options = [
           title: <<"Weather Models">>,
           controller: :weather,
           user_id: user_id
         ]
         {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(content, options), req
      _ ->
         content = weather_edit()
         options = [
           title: <<"Weather Model Editor">>,
           controller: :weather,
           user_id: user_id,
           blockly: true,
           scripts: ["/js/weather_editor.js"]
         ]
         {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(content, options), req
         
    end
    {:ok, req, state}
  end

  @doc """
    Shuts down the handler
  """
  def terminate(_reason, _request, _state) do
    :ok
  end

end
