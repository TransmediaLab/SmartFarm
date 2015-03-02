defmodule Plant do
  @moduledoc """
    Defines methods for interacting with an agent for modeling a species
    of plant within a SmartFarm simulation.
    
    The population is represented as a list of keyword lists, where each
    keyword list holds an individual plant's state.  Sowing adds new plant
    states to the list, and harvesting removes them.  Other actions, like
    updating the time of the simulation with tick, apply to all plants in
    the population.
  """

  require Record

  # A record for the plant agent model
  Record.defrecordp :model, :plant, id: nil, code: "", workspace: "", population: []

  @doc """
    Loads a plant model from the database and returns a plant agent
  """
  def load(id) do
    %Postgrex.Result{num_rows: 1, rows: [{id, code, workspace}]} = Postgrex.Connection.query!(:conn, "SELECT id, code, workspace FROM plants WHERE id = " <> to_string(id), [])
    {:ok, plant} = Agent.start_link(fn -> model(id: id, code: code, workspace: workspace, population: []) end)
    plant
  end

  @doc """
  Starts a new plant.
  -- need to add variables & support for
  -- custom code
  """
  def new do
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "INSERT INTO plants (user_id) VALUES (1);", [])
    %Postgrex.Result{rows: [{id}]} = Postgrex.Connection.query!(:conn, " SELECT currval(pg_get_serial_sequence('plants', 'id'));",[])
    load id
  end

  @doc """
    Establishes a new plant in the population at location {x, y}
  """
  def sow(plant, {x,y}) do
    seed = [x: x, y: y, biomass: 1] 
    Agent.update(plant, fn model(code: code, population: population)=m -> model(m, population: [seed|population]) end)
  end

  @doc """
    Returns the total biomass of the plant population
  """
  def biomass(plant) do
    Agent.get(plant, fn model(population: population) -> population end) 
    |> Enum.map(fn s -> Keyword.get(s, :biomass, 0) end) 
    |> Enum.sum
  end

  def to_svg() do
  end

  @doc """
    Advances the modeled plant population by one day
  """
  def tick(plant) do
    Agent.update(plant, fn model(code: code, population: pop)=m -> model(m, population: tick_helper(pop, code)) end)
  end

  # Tick helper recurses through the population, updating it with supplied code
  defp tick_helper([], code) do
    []
  end

  defp tick_helper([head|tail], code) do
    {_, new_state} = Code.eval_string(code, head)
    [new_state|tick_helper(tail, code)]
  end

end
