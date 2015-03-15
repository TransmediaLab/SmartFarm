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
  Record.defrecordp :model, :plant, id: nil, user_id: nil, name: "Unnamed Plant", description: "", code: "", workspace: "", population: []

  @doc """
    Loads a plant model from the database and returns a plant agent
  """
  def load(id) do
    data = Database.plant(id)
    {:ok, agent} = Agent.start_link(fn -> model(id: id, user_id: data.user_id, name: data.name, description: data.description, workspace: data.workspace, code: data.code) end)
    agent
  end

  @doc """
    Creates a new plant model agent for the specified user
  """
  def new(user_id) do
    {:ok, plant} = Agent.start_link(fn -> model(user_id: user_id) end)
    plant
  end

  @doc """
    Saves the current plant model and returns its id.
  """
  def save(plant) do
    model(id: id, user_id: user_id, name: name, description: description, code: code, workspace: workspace) = Agent.get(plant, fn s -> s end)
    id = Database.plant(id, %{user_id: user_id, name: name, description: description, code: code, workspace: workspace})
  end

  @doc """
    Clones the current plant model for the specified user, saves the clone
    to the database, and returns its id.
  """
  def clone(plant, user_id) do
    Agent.update(plant, fn s -> model(s, id: nil, user_id: user_id) end)
    save(plant)
  end

  @doc """
    Returns the plant model's user_id
  """
  def user_id(plant) do
    Agent.get(plant, fn model(user_id: user_id) -> user_id end)
  end

  @doc """
    Returns the plant model as a Map
  """
  def model_data(plant) do
    {name, description, code, workspace} = Agent.get(plant, fn model(name: name, description: description, code: code, workspace: workspace) -> {name, description, code, workspace} end)
    %{name: name, description: description, code: code, workspace: workspace}
  end

  @doc """
    Returns the current state of the plant model as a Map
  """
  def state(plant) do
    Agent.get(plant, fn model(population: pop) -> pop end)
      |> Enum.map fn p -> Enum.into p, %{} end
  end

  @doc """
    Changes the code for the specified plant model.
  """
  def change_code(plant, code, workspace) do
    Agent.update(plant, fn p -> model(p, code: code, workspace: workspace) end)
  end

  @doc """
    Returns the Blockly workspace for the plant model.
  """
  def workspace(plant) do
    Agent.get(plant, fn model(workspace: workspace) -> workspace end) |> String.replace("\"", "\\\"")
  end

  @doc """
    Returns the plant model's name
  """
  def name(plant) do
    Agent.get(plant, fn model(name: name) -> name end)
  end

  @doc """
    Sets the plant model's name to *name*
  """
  def name(plant, name) do
    Agent.update(plant, fn m -> model(m, name: name) end)
  end

  @doc """
    Gets the plant model's description
  """
  def description(plant) do
    Agent.get(plant, fn model(description: description) -> description end)
  end

  @doc """
    Sets the plant model's description to *description*
  """
  def description(plant, description) do
    Agent.update(plant, fn m -> model(m, description: description) end)
  end




  @doc """
    Establishes a new plant in the population at location {:point, x, y}
  """
  def sow(plant, {:point, x, y}) do
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
  def tick(plant, state) do
    Agent.update(plant, fn model(code: code, population: pop)=m -> model(m, population: tick_helper(pop, state, code)) end)
  end

  # Tick helper recurses through the population, updating it with supplied code
  defp tick_helper([], _state, _code) do
    []
  end

  defp tick_helper([head|tail], state, code) do
    {_, new_state} = Code.eval_string(code, Keyword.merge(head, state))
    [new_state|tick_helper(tail, state, code)]
  end

end
