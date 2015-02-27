defmodule SimulationWebSocketHandler do
  @moduledoc """
  This module upgrades an HTTP connection to a WebSocket that manages
  a SmartFarm simulation.  

  Because JavaScript measures time in milliseconds since 1/1/1970, we will
  use that representation for simulation time as well.

 {:ok, req, new_state} ->
        format_ok req, state(state, handler_state: new_state)

      {:reply, reply, req, new_state} ->
        format_reply req, reply, state(state, handler_state: new_state)

  """

  @step_delay 1000 

  @behaviour :cowboy_http_handler
  @behaviour :cowboy_websocket_handler

  # Requires
  require Poison
  require Record

  # A record to represent the simulation state
  Record.defrecord :state, paused: :true, time: 0, start: 0, weather: nil

  @doc"""
  Initialize the websocket server and set up the inital simulation state
  """
  def websocket_init(_any, req, opts) do

    # Set the simulation start time to right now
    {mega, sec, _micro} = :erlang.now
    start = (mega * 1000000 + sec) * 1000

    req = :cowboy_req.compact req
    req = :cowboy_req.set_resp_header("Sec-WebSocket-Protocol", "simulation-protocol", req)

    format_ok req, state(start: start, time: start)
  end

  # Dispatch generic message to the handler
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

      _ ->
          format_ok(req, state)

    end
  end

  # Default case
  def websocket_handle(_any, req, state) do
    format_ok req, state
  end

  # Various service messages

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
    data = Weather.state(weather)
    reply =  <<"{\"type\":\"weather\", \"data\":">> <> data <> <<"}">>
    format_reply req, reply, state(state, weather: weather)
  end

  def websocket_info(info, req, state) do
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
            { :upgrade, :protocol, :cowboy_websocket }
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
