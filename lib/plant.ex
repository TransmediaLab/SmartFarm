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
  Record.defrecordp :model, :plant, id: nil, user_id: nil, code: "", workspace: "", population: []

  @doc """
    Loads a plant model from the database and returns a plant agent
  """
  def load(id) do
    %Postgrex.Result{num_rows: 1, rows: [{user_id, code, workspace}]} = Postgrex.Connection.query!(:conn, "SELECT user_id, code, workspace FROM plants WHERE id = " <> to_string(id), [])
    {:ok, plant} = Agent.start_link(fn -> model(id: id, user_id: user_id, code: code, workspace: workspace, population: []) end)
    plant
  end

  @doc """
    Starts a new plant.
  """
  def new(user_id) do
    %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "INSERT INTO plants (user_id) VALUES (#{user_id});", [])
    %Postgrex.Result{rows: [{id}]} = Postgrex.Connection.query!(:conn, " SELECT currval(pg_get_serial_sequence('plants', 'id'));",[])
    load id
  end

  @doc """
    Changes the code for the specified plant model.
  """
  def change_code(plant, code, workspace) do
    Agent.update(plant, fn p -> model(p, code: code, workspace: workspace) end)
  end

  @doc """
    Saves the current plant model for the current user. 
    If this is the plant model's owner, the current database entry is overwritten.
    Otherwise, a clone of the plant is created.
  """
  def save(plant, current_user_id) do
    {id, user_id, code, workspace} = Agent.get(plant, fn model(id: id, user_id: user_id, code: code, workspace: workspace) -> {id, user_id, code, workspace} end)
IO.puts "CURRENT USER is #{inspect current_user_id}, OWNER is #{inspect to_string user_id}"
    if current_user_id == to_string(user_id) do
IO.puts "SAVING PLANT WITH MATCHING USER"
      Postgrex.Connection.query!(:conn, "UPDATE plants SET code='#{code}', workspace='#{workspace}' WHERE id=#{id}", [])
    else
IO.puts "CLONING PLANT"
      %Postgrex.Result{num_rows: 1, rows: [{name, description}]} = Postgrex.Connection.query!(:conn, "SELECT name, description FROM plants WHERE id=#{id}", [])
      %Postgrex.Result{num_rows: 1} = Postgrex.Connection.query!(:conn, "INSERT INTO plants (user_id, name, description, code, workspace) VALUES (#{current_user_id}, '#{name}', '#{description}', '#{code}', '#{workspace}');", [])
      %Postgrex.Result{rows: [{id}]} = Postgrex.Connection.query!(:conn, " SELECT currval(pg_get_serial_sequence('plants', 'id'));",[])  
      Agent.update(plant, fn s -> model(s, id: id, user_id: current_user_id) end)
    end
  end

  @doc """
    Establishes a new plant in the population at location {x, y}
  """
  def sow(plant, {x,y}) do
    seed = [x: x, y: y, biomass: 1] 
    Agent.update(plant, fn model(code: code, population: population)=m -> model(m, population: [seed|population]) end)
  end

  @doc """
    Returns the Blockly workspace for the plant model.
  """
  def workspace(plant) do
    Agent.get(plant, fn model(workspace: workspace) -> workspace end) |> String.replace("\"", "\\\"")
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
