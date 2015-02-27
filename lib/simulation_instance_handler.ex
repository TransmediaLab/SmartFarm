defmodule SimulationInstanceHandler do
  #@behaviour :simple_handler

  require Record
  require Weather

  @doc """
  A record for the simulation state
  """
  Record.defrecordp :state, paused: :true, start: 0, clock: 0, time: 0, latitude: 0, longitude: 0, weather: 0, soil_patches: [], plants: []

  @doc """
  Initializes the simulation websocket server
  """
  def init(_any, req) do
    :erlang.send(self(), :time)
    {:ok, req, state(paused: :true, clock: 1423980000000)}
  end


  @doc """
  Processes messages from the websocket client
  """
  def stream(json, req, state(clock: clock, weather: weather)) do
    msg = Poison.decode! json
    data = msg["data"]
    case msg["type"] do
      "load-weather" ->
        IO.puts("load weather")
        IO.puts( inspect msg["data"]["id"] )
        Process.exit(weather, :normal)
        {:ok, new_weather} = Weather.load msg["data"]["id"]
        {:ok, req, state(state, paused: true, clock: clock, weather: weather)}
      "run" ->
        IO.puts("resume")
        :erlang.send_after(50, self(), :tick)
        {:ok, req, state(state, paused: :false, clock: clock, weather: weather)}
      "pause" ->
        IO.puts("pause")
        {:ok, req, state(state, paused: :true, clock: clock, weather: weather)}
      "reset" ->
        IO.puts "reset"
        clock = 1423980000000
        :erlang.send(self(), :time)
        {:ok, req, state(state, paused: :true, clock: clock, weather: weather)}
      "step" ->
        IO.puts("step")
        IO.puts( inspect( state ))
        clock = clock + 86400000
        :erlang.send(self(), :time)
        Weather.tick(weather)
        IO.puts inspect( weather)
        :erlang.send(self(), :weather)
        {:ok, req, state(state, paused: true, clock: clock, weather: weather)}
      "update" ->
        IO.puts("update")
        IO.puts inspect(data) 
        Weather.change_code(weather, data["code"])
        Database.update_weather_model(1, data["workspace"])
        {:ok, req, state(state, paused: true, clock: clock, weather: weather)}
      _ ->
        {:ok, req, state(state, clock: clock, weather: weather)}
    end
  end


  # Received timer event
  def info(:tick, req, state = state(clock: clock, paused: :true)) do
    IO.puts("tick, paused")
    {:ok, req, state(state, clock: clock, paused: :true)}
  end

  def info(:tick, req, state = state(clock: clock, paused: false, weather: weather)) do
    IO.puts("tick, unpaused")
    clock = clock + 86400000
    :erlang.send(self(), :time)
    Weather.tick(weather)
    :erlang.send(self(), :weather)
    :erlang.send_after(50, self(), :tick)
    {:ok, req, state(state, clock: clock, paused: :false)}
  end

  def info(:time, req, state = state(clock: clock)) do
    {:reply,
      <<"{\"type\": \"time\", \"data\": {\"clock\":">> <> to_string(clock) <> <<"}}">>,
      req,
      state(state, clock: clock)}
  end    

  def info(:weather, req, state = state(weather: weather)) do
    IO.puts "sending weather"
    IO.puts( inspect( Weather.to_json(weather) ))
    data = Weather.to_json(weather)
    IO.puts(data)
    {:reply, 
      <<"{\"type\":\"weather\", \"data\":">> <> data <> <<"}">>, 
      req, 
      state(state, weather: weather)}
  end

  def info(_info, req, state) do
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end

