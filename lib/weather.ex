defmodule Weather do
  @moduledoc """
  Defines methods for interacting with a model for simulating weather 
  consisting of a state and update code.

  The state consists of the following variables:

  rainfall		in mm
  snowfall		in mm 
  average_temperature	in degrees C
  low_temperature		in degrees C
  high_temperature	in degrees C

  And the code is a snippet of Javascript, using the SmartFarm
  Javascript Weather API.
  """
  require Record
  require Execjs

  @doc """
  A weather model record
  """
  Record.defrecord :weather_model, WeatherModel, [
    code: <<"">>, 
    state: <<"{\"rainfall\": 0.0, \"snowfall\": 0.0, \"average_temperature\": 0.0, \"low_temperature\": 0.0, \"high_temperature\": 0.0}">> 
  ]

  @doc """
  Loads a weather model from the database
  """
  def load(id) do
    state = <<"{\"rainfall\": 0.0, \"snowfall\": 0.0, \"average_temperature\": 0.0, \"low_temperature\": 0.0, \"high_temperature\": 0.0}">>
    {_id, code, _workspace} = Database.weather_model id
    Agent.start_link(fn -> {:weather_model, code, state} end)
  end

  @doc """
  Starts a new weather process.
  -- need to add variables & support for
  -- custom code
  """
  def start_link(model) do
    code = weather_model(model, :code)
    state = weather_model(model, :state)
    Agent.start_link(fn -> {:weather_model, code, state} end)
  end

  @doc """
    Returns the current state of `weather` as JSON
  """
  def to_json(weather) do
    {:weather_model, _code, state} = Agent.get(weather, fn s -> s end)
    state
  end

  @doc """
    Changes the update code of `weather` to the supplied `code`
  """
  def change_code(weather, code) do
    Agent.update(weather, fn {:weather_model, _old_code, state} -> {:weather_model, code, state} end)
  end


  @doc """
  Advances the simulation state for the supplied `weather`.
  """
  def tick(weather) do
    {:weather_model, code, state} = Agent.get(weather, fn s -> s end)
    
    # Convert weather state to a Javascript object
    js = "var weather = " <>  state #to_string Poison.Encoder.encode(state, [])
    
    # Load the Weather Model's Javascript API
    js = js <> """
 
      function set_rainfall(value){ weather.rainfall = value;}
      function set_snowfall(value){ weather.snowfall = value; }
      function set_average_temperature(value){ weather.average_temperature = value}
      function set_low_temperature(value){ weather.low_temperature = value;}
      function set_high_temperature(value) { weather.high_temperature = value;}

      function get_rainfall(){ return weather.rainfall; }
      function get_snowfall(){ return weather.snowfall; }
      function get_average_temperature(){ return weather.average_temperature; }
      function get_low_temperature(){ return weather.low_temperature; }
      function get_high_temperature(){ return weather.high_temperature; }

    """

    # Apply the Javascript Weather update functionality
    js = js <> code 
    js = js <> ";\nweather"

    # Update the `weather` state by running the Javascript code
    new_state = Execjs.eval(js) |> Poison.encode! |> to_string
    Agent.update(weather, fn _ -> {:weather_model, code, new_state} end)

  end


end
