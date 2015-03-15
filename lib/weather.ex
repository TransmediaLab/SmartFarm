defmodule Weather do
  @moduledoc """
    Defines methods for interacting with an agent for modeling weather
    within a SmartFarm simulation.
  """

  require EEx
  require Record

  # A record for the weather agent model
  Record.defrecordp :model, id: nil, user_id: nil, name: <<"Unnamed Weather">>, description: <<"">>, workspace: <<"">>, code: <<"">>, state: []

  @doc """
    Loads a weather model from the database and returns a weather agent
  """
  def load(id) do
    data = Database.weather(id)
    {:ok, agent} = Agent.start_link(fn -> model(id: id, user_id: data.user_id, name: data.name, description: data.description, workspace: data.workspace, code: data.code) end)
    agent
  end

  @doc """
    Creates a new weather model agent for the specified user
  """
  def new(user_id) do
    {:ok, weather} = Agent.start_link(fn -> model(user_id: user_id) end)
    weather
  end

  @doc """
    Saves the current weather model and returns its id.
  """
  def save(weather) do
    model(id: id, user_id: user_id, name: name, description: description, code: code, workspace: workspace) = Agent.get(weather, fn s -> s end)
    id = Database.weather(id, %{user_id: user_id, name: name, description: description, code: code, workspace: workspace})
  end

  @doc """
    Clones the current weather model for the specified user, saves the clone
    to the database, and returns its id.
  """
  def clone(weather, user_id) do
    Agent.update(weather, fn s -> model(s, id: nil, user_id: user_id) end)
    save(weather)
  end

  @doc """
    Returns the weather model as a Map
  """
  def model_data(weather) do
    {name, description, code, workspace} = Agent.get(weather, fn model(name: name, description: description, code: code, workspace: workspace) -> {name, description, code, workspace} end)
    %{name: name, description: description, code: code, workspace: workspace}
  end

  @doc """
    Returns the weather model's user_id
  """
  def user_id(weather) do
    Agent.get(weather, fn model(user_id: user_id) -> user_id end)
  end

  @doc """
    Returns the current state of the weather model as a Map
  """
  def state(weather) do
    Agent.get(weather, fn model(state: state) -> state end)
      |> Enum.into %{}
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
    Agent.update(weather, fn s -> model(s, workspace: workspace, code: code) end)
  end

  @doc """
    Advances the weather model by one day
  """
  def tick(weather, simulation_state \\ []) do
    {code, state} = Agent.get(weather, fn model(code: code, state: state) -> {code, state} end)
    state = Keyword.merge(state, simulation_state)
    {_, new_state} = Code.eval_string(code, state)
    Agent.update(weather, fn m -> model(m, state: new_state) end)
  end

  @doc """
    Returns the weather model's name
  """
  def name(weather) do
    Agent.get(weather, fn model(name: name) -> name end)
  end

  @doc """
    Sets the weather model's name to *name*
  """
  def name(weather, name) do
    Agent.update(weather, fn m -> model(m, name: name) end)
  end

  @doc """
    Gets the weather model's description
  """
  def description(weather) do
    Agent.get(weather, fn model(description: description) -> description end)
  end

  @doc """
    Sets the weather model's description to *description*
  """
  def description(weather, description) do
    Agent.update(weather, fn m -> model(m, description: description) end)
  end

end
