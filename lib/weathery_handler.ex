defmodule WeatheryHandler do

  require EEx
  require Weather

  EEx.function_from_file :defp, :weather_index, "priv/templates/weather_index.html.eex", [:models]
  EEx.function_from_file :defp, :weather_edit,  "priv/templates/weather_edit.html.eex",  [:workspace]
  EEx.function_from_file :defp, :weather_model, "priv/templates/weather_model.html.eex", [:id, :name, :desc]

  def init({ _any, :http }, req, []) do
    { :ok, req, :undefined }
  end

  def handle(req, state) do
    { id, req} = :cowboy_req.binding(:id, req, :all)
    {:ok, req} = serve(id, req)
    {:ok, req, state}
  end

  def terminate(_reason, _request, _state) do
    :ok
  end

  defp serve(:all, req) do
    models = Database.list_weather_models()
    head = Layout.head("Weather Models", [])
    nav = Layout.nav(:weather)
    models = Enum.map_join(models, "\n", fn({id, name, description}) -> weather_model(id, name, description) end)
    content = weather_index(models)
    {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(head, nav, content), req
  end

  defp serve(id, req) do
    IO.puts id
    {id, code, workspace} = Database.weather_model(id)
    head = Layout.head("Weather Model Editor", [:blockly, :controls])
    nav = Layout.nav(:weather)
    content = weather_edit(workspace)
    {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(head, nav, content), req
  end

end
