defmodule WeatherHandler do
  #@behaviour :simple_handler
  IO.puts "Weather"

  require Record
  Record.defrecordp :state, paused: :true, clock: 0, weather: 0

  require Weather

  def init(_any, req) do
    IO.puts("init")
    {:ok, weather} = Weather.start_link(Weather.weather_model())
    :erlang.send(self(), :time)
    {:ok, req, state(paused: :true, clock: 1423980000000, weather: weather)}
  end

  def stream("reset\n", req, state) do
    IO.puts("reset")
    clock = 1423980000000
    :erlang.send(self(), :time)
    {:ok, req, state(state, paused: :true, clock: clock)}
  end

  def stream("pause\n", req, state) do
    IO.puts("pause")
    {:ok, req, state(state, paused: :true)}
  end

  def stream("resume\n", req, state) do
    IO.puts("resume")
    :erlang.send_after(50, self(), :tick)
    {:ok, req, state(state, paused: :false)}
  end

  def stream("step\n", req, state = state(clock: clock, weather: weather)) do
    IO.puts("step")
    IO.puts( inspect( state ))
    clock = clock + 86400000
    :erlang.send(self(), :time)
    Weather.tick(weather)
    IO.puts inspect( weather)
    :erlang.send(self(), :weather)
    {:ok, req, state(state, clock: clock, weather: weather, paused: :true)}
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

