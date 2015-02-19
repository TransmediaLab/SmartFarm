defmodule WeatherTest do
  use ExUnit.Case
  require Weather
  require Poison

  test "Weather.start_link should initalize an agent with supplied js code" do
    {:ok, weather} = Weather.start_link( Weather.weather_model(code: "var foo = 'bar';") )
    {:weather_model, code, _state} = Agent.get(weather, fn s -> s end)
    assert code == "var foo = 'bar';"
  end

  test "Weather.start_link should initalize an agent that possesses all weather state attributes" do
    {:ok, weather} = Weather.start_link( Weather.weather_model() )
    {:weather_model, _code, state} = Agent.get(weather, fn s -> s end)
    {:ok, state} = Poison.Parser.parse(state)
    assert Map.has_key?(state, "rainfall")
    assert Map.has_key?(state, "snowfall")
    assert Map.has_key?(state, "average_temperature")
    assert Map.has_key?(state, "low_temperature")
    assert Map.has_key?(state, "high_temperature")
  end

  test "Weather.to_json should return current state of weather as JSON" do
    json = <<"{\"rainfall\": 0.0, \"snowfall\": 0.0, \"average_temperature\": 0.0, \"low_temperature\": 0.0, \"high_temperature\": 0.0}">>
    {:ok, weather} = Weather.start_link( Weather.weather_model() )
    {:weather_model, _code, state} = Agent.get(weather, fn s -> s end)
    assert state == json    
  end

  test "Weather.change_code should replace prior code with supplied code" do
    {:ok, weather} = Weather.start_link( Weather.weather_model(code: "var foo = 5;") )
    Weather.change_code(weather, "var foo = 'bar';");
    {:weather_model, code, _state} = Agent.get(weather, fn s -> s end)
    assert code == "var foo = 'bar';"
  end

  test "Supplied javascript code should be able to set and get rainfall state" do
    {:ok, weather} = Weather.start_link( Weather.weather_model(code: "set_rainfall(20);") )
    Weather.tick(weather) 
    {:weather_model, _code, state} = Agent.get(weather, fn s -> s end)
    {:ok, state} = Poison.Parser.parse(state)
    {:ok, rainfall} = Map.fetch(state, "rainfall") 
    assert rainfall == 20
    Weather.change_code(weather, "set_rainfall(get_rainfall()+10);")
    Weather.tick(weather)
    {:weather_model, _code, state} = Agent.get(weather, fn s -> s end)
    {:ok, state} = Poison.Parser.parse(state)
    {:ok, rainfall} = Map.fetch(state, "rainfall") 
    assert rainfall == 30
  end




end
