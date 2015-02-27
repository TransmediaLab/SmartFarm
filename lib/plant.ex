defmodule Plant do

  require Record

  Record.defrecord :model, biomass: 0, lei: 0

  @doc """
  Starts a new plant.
  -- need to add variables & support for
  -- custom code
  """
  def start_link do
    Agent.start_link(fn -> model(biomass: 10) end)
  end

  def biomass(plant) do
    IO.puts inspect Agent.get(plant, fn s -> s end)
  end

  @doc """
  Advances the plant simulation, using
  the supplied `weather` conditions.
  """
  def tick(plant, _weather) do
    IO.puts("I am a plant. Hear me grow!")
  end

  @doc """
  Sows the plant's seed in the `soil`
  """
  def sow(plant, _soil) do
    IO.puts("I just got planted!")
  end

  @doc """
  Harvests the plant, returning a yield
  """
  def harvest(plant) do
    IO.puts("I just got harvested!")
    {:yield, 450, 0.20}
  end

  @doc """
  Tills the plant, killing it and putting
  its biomass into the soil
  """
  def till(plant) do
    IO.puts("I just got tilled. Goodbye.")
  end


end
