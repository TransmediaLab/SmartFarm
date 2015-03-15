defmodule PlantWebSocketHandler do
  @moduledoc """
    This module upgrades an HTTP connection to a WebSocket that manages
    a SmartFarm plant model editing session.  
    
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

  # A record to represent the plant editor state
  Record.defrecord :state, user_id: nil, paused: :true, time: 0, start: 0, weather: nil, plant: nil

  @doc"""
  Initialize the websocket server and set up the inital simulation state
  """
  def websocket_init(_any, req, opts) do
    # Get the user id for the signed-in user
    user_id = Keyword.get opts, :user_id

    # Load the appropriate plant model
    plant_id = Keyword.get(opts, :id)
    case plant_id do
      "new" ->
         plant = Plant.new(user_id)
      _ ->
         plant = Plant.load(plant_id)
    end

    # Plant a single seed at the origin
    Plant.sow(plant, {:point, 0, 0})

    # Send the client the plant
    :erlang.send self(), :plant

    # Set the simulation start time to right now
    {mega, sec, _micro} = :erlang.now
    start = (mega * 1000000 + sec) * 1000

    req = :cowboy_req.compact req
    format_ok req, state(user_id: user_id, start: start, time: start, plant: plant)
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
    name		| text
    description		| text
    change-code		| text/json {workspace : <Blockly workspace as xml string>, code: <JavaScript code equivalent>}
    save		| none
  """  
  def websocket_handle({:text, msg}, req, state(user_id: user_id, plant: plant)=state) do
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

      "name" ->
          Plant.name(plant, json["data"])
          format_ok(req, state)

      "description" ->
          Plant.description(plant, json["data"])
          format_ok(req, state)

      "save" ->
         if user_id == :undefined do
           format_reply(req, "{\"type\":\"not-logged-in\"}", state)
         else
           if to_string(Plant.user_id(plant)) == user_id do
             id = Plant.save(plant)
           else
             id = Plant.clone(plant, user_id)
           end
           format_reply(req, "{\"type\":\"new-id\",\"data\":#{id}}", state)
         end

      "change-code" ->
          Plant.change_code(plant, json["data"]["code"], json["data"]["workspace"])
          format_ok(req, state)

      msg ->
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
  def websocket_info(:step, req, state(time: time, paused: paused, weather: weather, plant: plant)=state) do

    # advance simulation by one day
    time = time + 86400000 
    simState = [simulation_time: time]

    # advance the weather model (if in use)
    if(weather != nil) do
      Weather.tick(weather, simState)
      simState = Keyword.merge(Weather.state(weather), simState)
    end

    # advance the plant model
    Plant.tick(plant, simState)

    # schedule next update
    if !paused do :erlang.send_after @step_delay, self(), :step end

    reply = %{type: "state", data: %{simulation_time: time, plants: Plant.state(plant)}}
      |> Poison.encode!
      |> to_string

    format_reply req, reply, state(state, time: time, paused: paused)
  end


  @doc """
    Sends the plant model data to the client
  """
  def websocket_info(:plant, req, state(plant: plant)=state) do
    reply = %{type: "plant", data: Plant.model_data(plant)}
      |> Poison.encode!
      |> to_string
    format_reply req, reply, state
  end

  @doc """
    Ignores unknown info messages
  """
  def websocket_info(_info, req, state) do
    format_ok req, state
  end

  @doc """
    Closes the handler
  """
  def websocket_terminate(_reason, _req, _state) do
    :ok
  end


  ## This is the HTTP part of the handler. It will only start up
  ## properly, if the request is asking to upgrade the protocol to
  ## WebSocket

  def init({_any, :http}, req, _opts) do
    case :cowboy_req.header("upgrade", req) do
      {bin, req} when is_binary(bin) ->
        case :cowboy_bstr.to_lower(bin) do
          "websocket" ->
            {id, req} = :cowboy_req.binding(:id, req, nil)
            {user_id, req} = :cowboy_req.cookie(<<"userid">>, req)
            { :upgrade, :protocol, :cowboy_websocket, req, [id: id, user_id: user_id] }
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

  defp not_implemented(req) do
    { :ok, req } = :cowboy_req.reply(501, [], [], req)
    { :shutdown, req, :undefined }
  end

  defp format_ok(req, state) do
    {:ok, req, state, :hibernate}
  end

  defp format_reply(req, reply, state) do
    {:reply, {:text, reply}, req, state, :hibernate}
  end

end
