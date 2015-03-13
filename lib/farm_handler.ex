defmodule FarmHandler do
  @moduledoc """
    Handles farm-related http requests
  """

  require EEx
  require Farm

  # HTML page template functions
  EEx.function_from_file :defp, :farm_index, "priv/templates/farms/index.html.eex", [:farms, :user_filters]
  EEx.function_from_file :defp, :farm_new,   "priv/templates/farms/new.html.eex",   []
  EEx.function_from_file :defp, :farm_edit,  "priv/templates/farms/edit.html.eex",  []
  EEx.function_from_file :defp, :farm_model, "priv/templates/farms/model.html.eex", [:id, :user_id, :username, :name, :description]
  EEx.function_from_file :defp, :filter,     "priv/templates/search/user_filter.html.eex", [:user_id, :username]

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
          content = farm_new()
          options = [
            title: <<"Create New Farm">>,
            controller: :farms,
            user_id: user_id,
            maps: true,
            scripts: ["/js/farm_editor.js"]
          ]
          {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(content, options), req
      :all ->
         {xhr, req} = :cowboy_req.header(<<"x-requested-with">>, req)
         if(xhr == "XMLHttpRequest") do
           {query, req} = :cowboy_req.qs_vals(req)
           reply = Database.list_farms(query, 0)
             |> Enum.map(fn {id, user_id, username, name, desc} -> farm_model(id, user_id, username, name, desc) end)
           {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], reply, req
         else
           user_filters = [{user_id, Database.user(user_id).username}] 
             |> Enum.map(fn {uid, uname} -> filter(uid, uname) end)
             |> Enum.join
           content = Database.list_farms 
             |> Enum.map(fn {id, user_id, username, name, desc} -> farm_model(id, user_id, username, name, desc) end)
             |> farm_index(user_filters)
           options = [
             title: <<"Farm Models">>,
             controller: :farms,
             user_id: user_id,
             scripts: ["js/search.js"]
           ]
           {:ok, req} = :cowboy_req.reply 200, [{"Content-Type", "text/html"}], Layout.page(content, options), req
         end
      _ ->
         options = [
           title: <<"Farm Model Editor">>, 
           controller: :plants, 
           user_id: user_id,
           maps: true,
           scripts: ["/js/farm_editor.js"]
         ]
         content = farm_edit()
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
