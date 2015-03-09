defmodule PlantHandler do
  @moduledoc """
    Handles plant-related http requests
  """

  require EEx
  require Plant

  # HTML page template functions
  EEx.function_from_file :defp, :plant_edit,  "priv/templates/plants/edit.html.eex",  [:id, :controls, :blockly]
  EEx.function_from_file :defp, :plant_model, "priv/templates/plants/model.html.eex", [:id, :name, :description]

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
IO.puts "USER_ID IS #{user_id}"
    { id, req} = :cowboy_req.binding(:id, req, :all)
    case id do
      :all ->
         %Postgrex.Result{rows: rows} = Postgrex.Connection.query!(:conn, "SELECT id, name, description FROM plants;", [])
         content = Enum.map(rows, fn {id, name, desc} -> plant_model(id, name, desc) end)
         options = [
           title: <<"Plant Models">>,
           controller: :plants,
           user_id: user_id
         ]
         {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(content, options), req
      id ->
         options = [
           title: <<"Plant Model Editor">>, 
           controller: :plants, 
           user_id: user_id, 
           blockly: :true, 
           controls: :true
         ]
         content = plant_edit(id, Layout.controls(), Layout.blockly())
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
