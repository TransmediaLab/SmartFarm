defmodule WeatherHandler do
  @moduledoc """
    Handles weather-related http requests
  """

  require EEx
  require Weather

  # HTML page template functions
  EEx.function_from_file :defp, :weather_index, "priv/templates/weather_index.html.eex", [:models]
  EEx.function_from_file :defp, :weather_edit,  "priv/templates/weather_edit.html.eex",  [:id, :workspace]
  EEx.function_from_file :defp, :weather_model, "priv/templates/weather_model.html.eex", [:id, :name, :desc]

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
    { id, req} = :cowboy_req.binding(:id, req, :all)
    {:ok, req} = serve(id, req)
    {:ok, req, state}
  end

  @doc """
    Shuts down the handler
  """
  def terminate(_reason, _request, _state) do
    :ok
  end

  # Private API

  defp serve(:all, req) do
    models = Database.list_weather_models()
    head = Layout.head("Weather Models", [])
    nav = Layout.nav(:weather)
    models = Enum.map_join(models, "\n", fn({id, name, description}) -> weather_model(id, name, description) end)
    content = weather_index(models)
    {:ok, _req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(head, nav, content), req
  end

  defp serve(id, req) do
    {id, code, workspace} = Database.weather_model(id)
    head = Layout.head("Weather Model Editor", [:blockly, :controls])
    nav = Layout.nav(:weather)
    content = weather_edit(id, workspace)
    {:ok, _req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(head, nav, content), req
  end

end
