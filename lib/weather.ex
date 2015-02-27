defmodule Weather do
  @moduledoc """
    Defines methods for interacting with an agent for modeling weather
    within a SmartFarm simulation.
  """

  require Record
  require Execjs

  # A record for the weather agent model
  Record.defrecordp :model, id: nil, workspace: <<"">>, code: <<"">>, state: <<"">>

  @doc """
    Loads a weather model from the database and returns a weather agent
  """
  def load(id) do
    result = Postgrex.Connection.query!(:conn, "SELECT code, workspace FROM weather_model WHERE id = " <> to_string(id), []) 
    [{code, workspace} | _tail]  = result.rows
    state = <<"{}">>
    {:ok, agent} = Agent.start_link(fn -> model(id: id, workspace: workspace, code: code, state: state) end)
    agent
  end

  @doc """
    Returns the current state of the weather model as a JSON string
  """
  def state(weather) do
    model(state: state) = Agent.get(weather, fn s -> s end)
    state
  end

  @doc """
    Returns the current workspace as an XML string
  """
  def workspace(weather) do
    model(workspace: workspace) = Agent.get(weather, fn s -> s end)
    workspace |> String.replace "\"", "\\\""
  end

  @doc """
    Swaps out the weather model's workspace and code for the provided arguments
  """
  def change_code(weather, workspace, code) do
    model(id: id) = Agent.get(weather, fn s -> s end)
    Postgrex.Connection.query!(:conn, "UPDATE weather_model SET workspace='" <> workspace <> "', code='" <> code <> "' WHERE id = " <> to_string(id), [])
    Agent.update(weather, fn s -> model(s, workspace: workspace, code: code) end)
  end


  @doc """
    Advances the weather model's state by one day 
  """
  def tick(weather) do
    model(code: code, state: state) = Agent.get(weather, fn s -> s end)
    
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
    Agent.update(weather, fn s -> model(s, state: new_state)  end)

  end

end
