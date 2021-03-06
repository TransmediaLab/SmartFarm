defmodule SimulationWebSocketHandler do
  @moduledoc """
    This module upgrades an HTTP connection to a WebSocket that manages
    a SmartFarm simulation.  
    
    Because JavaScript measures time in milliseconds since 1/1/1970, we will
    use that representation for simulation time as well.
  """

  @step_delay 1000 

  @behaviour :cowboy_http_handler
  @behaviour :cowboy_websocket_handler

  # Requires
  require Poison
  require Record
  require EEx

  EEx.function_from_file :defp, :html_weather_status, "priv/templates/weather_status.html.eex", [:weather, :date]

  # A record to represent the simulation state
  Record.defrecord :state, user_id: nil, paused: :true, time: 0, start: 0, weather: nil, plants: []

  @doc"""
  Initialize the websocket server and set up the inital simulation state
  """
  def websocket_init(_any, req, opts) do
    # Get the user id for the signed-in user
    user_id = Keyword.get opts, :user_id
IO.puts "USER ID IN WS IS #{user_id}"
    # Set the simulation start time to right now
    {mega, sec, _micro} = :erlang.now
    start = (mega * 1000000 + sec) * 1000

    req = :cowboy_req.compact req
    req = :cowboy_req.set_resp_header("Sec-WebSocket-Protocol", "simulation-protocol", req)

    format_ok req, state(user_id: user_id, start: start, time: start)
  end


  @doc """ 
    Handles websocket messages.  These should be JSON strings in the form
    {type: <type>, data: <data>} from:

    type 		| data
    ====================|======
    run  		| none
    pause		| none
    reset		| none
    step 		| none
    name  		| <name as a string>
    description		| text
    code-change		| workspace : <Blockly workspace as xml string>, code: <Elixir code equivalent>

  """  
  def websocket_handle({:text, msg}, req, state) do
    json = Poison.decode! msg
    case json["type"] do

      # Control messages
      "run" ->
          :erlang.send(self(), :step)
          format_ok(req, state(state, paused: false))

      "pause" ->
          format_ok(req, state(state, paused: true))

      "reset" ->
          state(start: start) = state
          reply = <<"{\"type\": \"time\", \"data\": {\"clock\":">> <> to_string(start) <> <<"}}">>
          format_reply(req, reply, state(state, paused: true, time: start))

      "step" ->
          :erlang.send self(), :step
          format_ok(req, state)

      # Weather messages
      "load-weather" ->
          IO.puts "Loading weather"
          weather = Weather.load json["data"]["id"]
          workspace = Weather.workspace(weather)
          reply = <<"{\"type\": \"workspace\", \"data\":\"">> <> workspace <> <<"\"}">>
          format_reply(req, reply, state(state, weather: weather))

      "update-weather" ->
          IO.puts("update weather")
          state(weather: weather) = state
          Weather.change_code(weather, json["data"]["workspace"], json["data"]["code"])
          Database.update_weather_model(1, json["data"]["workspace"])
          format_ok(req, state)

      # Plant messages
      "load-plants" ->
          IO.puts "Loading plant"
          plant = Plant.load json["data"]["id"]
          workspace = Plant.workspace(plant)
          reply = <<"{\"type\": \"workspace\", \"data\":\"">> <> workspace <> <<"\"}">>
          format_reply(req, reply, state(state, plants: [plant]))

      "change-plants" ->
          state(plants: [plant]) = state
          Plant.change_code(plant, json["data"]["code"], json["data"]["workspace"])
          format_ok(req, state)

      "save-plants" ->
          state(user_id: user_id, plants: [plant]) = state
          Plant.save(plant, user_id)
          format_ok(req, state)

      msg ->
IO.puts inspect msg
          format_ok(req, state)

    end
  end

  # Default case
  def websocket_handle(_any, req, state) do
    format_ok req, state
  end


  @doc """
    Advances the simulation by one step, triggering advances for all models currently
    defined in the simulation.  It also schedules the next simulation step unless
    the simulation is currently paused, and sends the client an updated time.
  """
  def websocket_info(:step, req, state(time: time, paused: paused)=state) do

    # advance simulation by one day
    time = time + 86400000 

    # advance the simulation models
    state(weather: weather) = state
    if weather do :erlang.send self(), :weather end

    # schedule next update
    if !paused do :erlang.send_after @step_delay, self(), :step end

    reply = <<"{\"type\": \"time\", \"data\": {\"clock\":">> <> to_string(time) <> <<"}}">>
    format_reply req, reply, state(state, time: time, paused: paused)
  end

  @doc """
    Advances the weather simulation and sends the updated weather state to the client
  """
  def websocket_info(:weather, req, state(weather: weather)=state) do
    Weather.tick(weather)
IO.puts inspect Weather.state(weather) |> Poison.decode!
    data = Weather.state(weather) |> Poison.decode! |> html_weather_status "Jan 1st"
    reply =  <<"{\"type\":\"weather\", \"data\":">> <> String.replace(data, "\"", "\\\"") <> <<"}">>
    format_reply req, reply, state(state, weather: weather)
  end

  def websocket_info(_info, req, state) do
    format_ok req, state
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end


  ## This is the HTTP part of the handler. It will only start up
  ## properly, if the request is asking to upgrade the protocol to
  ## WebSocket

  defp not_implemented(req) do
    { :ok, req } = :cowboy_req.reply(501, [], [], req)
    { :shutdown, req, :undefined }
  end

  def init({_any, :http}, req, _opts) do
    case :cowboy_req.header("upgrade", req) do
      {bin, req} when is_binary(bin) ->
        case :cowboy_bstr.to_lower(bin) do
          "websocket" ->
            {user_id, req} = :cowboy_req.cookie(<<"userid">>, req)
            { :upgrade, :protocol, :cowboy_websocket, req, [user_id: user_id] }
          _ ->
            not_implemented req
        end
      {:undefined, req} ->
        not_implemented req
    end
  end

  def handle(req, _state) do
    not_implemented req
  end

  def terminate(_reason, _req, _state) do
    :ok
  end


  ## Private API

  defp format_ok(req, state) do
    {:ok, req, state, :hibernate}
  end

  defp format_reply(req, reply, state) do
    {:reply, {:text, reply}, req, state, :hibernate}
  end
end
