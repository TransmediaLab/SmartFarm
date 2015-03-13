defmodule WeatherHandler do
  @moduledoc """
    Handles weather-related http requests
  """

  require EEx
  require Weather

  # HTML page template functions
  EEx.function_from_file :defp, :weather_index, "priv/templates/weather/index.html.eex", [:models, :user_filters]
  EEx.function_from_file :defp, :weather_edit,  "priv/templates/weather/edit.html.eex",  []
  EEx.function_from_file :defp, :weather_model, "priv/templates/weather/model.html.eex", [:id, :user_id, :username, :name, :description]
  EEx.function_from_file :defp, :filter,	"priv/templates/search/user_filter.html.eex", [:user_id, :username]

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
         {xhr, req} = :cowboy_req.header(<<"x-requested-with">>, req)
         if(xhr == "XMLHttpRequest") do
           {query, req} = :cowboy_req.qs_vals(req)
           reply = Database.list_weather(query, 0)
             |> Enum.map(fn {id, user_id, username, name, desc} -> weather_model(id, user_id, username, name, desc) end)
           {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], reply, req
         else
           user_filters = [{user_id, Database.user(user_id).username}]
             |> Enum.map(fn {uid, uname} -> filter(uid, uname) end)
             |> Enum.join
           content = Database.list_weather
             |> Enum.map(fn {id, user_id, username, name, desc} -> weather_model(id, user_id, username, name, desc) end)
             |> weather_index(user_filters)
           options = [
             title: <<"Weather Models">>,
             controller: :weather,
             user_id: user_id,
             scripts: ["js/search.js"]
           ]
           {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(content, options), req
         end
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
