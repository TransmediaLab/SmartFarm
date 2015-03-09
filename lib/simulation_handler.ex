defmodule SimulationHandler do
  @moduledoc """
    Handles simulation-related http requests
  """

  require EEx
  require Plant

  # HTML page template functions
  EEx.function_from_file :defp, :simulations_new,	"priv/templates/simulations/new.html.eex", []
  #EEx.function_from_file :defp, :plant_edit,  "priv/templates/plants/edit.html.eex",  [:id, :controls, :blockly]
  #EEx.function_from_file :defp, :plant_model, "priv/templates/plants/model.html.eex", [:id, :name, :description]

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
    { id, req} = :cowboy_req.binding(:id, req, :all)
    case id do
      "new" ->
         content = simulations_new()
         options = [
           title: <<"New Simulation">>, 
           controller: :simulations, 
           user_id: user_id, 
           controls: :true
         ]
         {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(content, options), req         
      :all ->
         #%Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT id, name, description FROM simulations;", [])
         content = "Coming Soon" #Enum.map(rows, fn {id, name, desc} -> plant_model(id, name, desc) end)
         options = [
           title: <<"Simulations">>,
           controller: :simulations,
           user_id: user_id
         ]
         {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(content, options), req
      id ->
         content = "coming soon" # plant_edit(id, Layout.controls(), Layout.blockly())
         options = [
           title: <<"Simulator">>, 
           controller: :simulations, 
           user_id: user_id, 
           controls: :true
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
    {id, _code, workspace} = Database.weather_model(id)
    head = Layout.head("Weather Model Editor", [:blockly, :controls])
    nav = Layout.nav(:weather)
    content = weather_edit(id, workspace)
    {:ok, _req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(head, nav, content), req
  end

end
