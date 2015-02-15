defmodule Schema do
  require Record

  @doc """
  A weather model record
  """
  Record.defrecord :weather_model, WeatherModel, [
    id: 0,
    user_id: 1,
    code: "",
    state: ~s({"rainfall": 0.0, "snowfall": 0.0, "average_temperature": 0.0, "low_temperature": 0.0, "high_temperature": 0.0})
  ]

  def setup do
    :mnesia.create_schema([node()])
    :mnesia.start()
    :mnesia.create_table(WeatherModel, [{:attributes, [:id, :user_id, :code, :state]}])
  end

  def seed do

    f = fn ->
      :mnesia.write(WeatherModel, weather_model(), :write)
      :mnesia.write(WeatherModel, weather_model(id: 2, code: "var foo = 5;"), :write)
    end

    :mnesia.transaction(f)
  end



end
