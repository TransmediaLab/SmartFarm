defmodule Farm do
  @moduledoc """
    Defines methods for interacting with an agent for modeling a farm
    within a SmartFarm simulation.
    
    The farm is represented as a list of keyword lists, where each
    keyword list holds an individual field's state.  Actions like
    updating the time of the simulation with tick apply to all fields
    in the farm.
  """

  require Record

  # A record for the farm agent model
  Record.defrecordp :model, :farm, id: nil, user_id: nil, name: "Unnamed Farm", description: "", latitude: 39.2113, longitude: -96.5992, fields: <<"[]">>

  @doc """
    Loads a farm from the database
  """
  def load(id) do
    data = Database.farm(id)
    {:ok, farm} = Agent.start_link(fn -> model(id: id, user_id: data.user_id, name: data.name, description: data.description, fields: data.fields) end)
    farm
  end

  @doc """
    Creates a new farm for the specified user
  """
  def new(user_id) do
    {:ok, farm} = Agent.start_link(fn -> model(user_id: user_id) end)
    farm 
  end

  @doc """
    Saves the current farm model and returns its id.
  """
  def save(farm) do
    model(id: id, user_id: user_id, name: name, latitude: latitude, longitude: longitude, description: description, fields: fields) = Agent.get(farm, fn s -> s end)
    id = Database.farm(id, %{user_id: user_id, name: name, description: description, latitude: latitude, longitude: longitude, fields: fields})
  end

  @doc """
    Clones the current farm model for the specified user, saves the clone
    to the database, and returns its id.
  """
  def clone(farm, user_id) do
    Agent.update(farm, fn s -> model(s, id: nil, user_id: user_id) end)
    save(farm)
  end

  @doc """
    Returns the current farm model in JSON format
  """
  def to_json(farm) do
    {name, latitude, longitude, description, fields} = Agent.get(farm, fn model(name: name, latitude: latitude, longitude: longitude, description: description, fields: fields) -> {name, latitude, longitude, description, fields} end) 
    fields = Poison.decode! fields
    %{name: name, latitude: latitude, longitude: longitude, description: description, fields: fields}
    |> Poison.encode!
    |> to_string    
  end

  @doc """
    Returns the farm owner's user_id
  """
  def user_id(farm) do
    Agent.get(farm, fn model(user_id: user_id) -> user_id end)
  end

  @doc """
    Returns the farm's name as a string
  """
  def name(farm) do
    Agent.get(farm, fn model(name: name) -> name end)
  end

  @doc """
    Updates a farm's name to the provided string
  """
  def name(farm, name) do 
    Agent.update(farm, fn s -> model(s, name: name) end)
  end

  @doc """
    Returns the farm's description as a string
  """
  def description(farm) do
    Agent.get(farm, fn model(description: description) -> description end)
  end

  @doc """
    Updates a farm's description to the provided string
  """
  def description(farm, description) do
    Agent.update(farm, fn s -> model(s, description: description) end)
  end

  @doc """
    Returns a farm's field boundaries as a JSON object
  """
  def fields(farm) do
    Agent.get(farm, fn model(fields: fields) -> fields end)
  end

  @doc """
    Updates a farm's field boundaries as a JSON object
  """
  def fields(farm, fields) do
    Agent.update(farm, fn s -> model(s, fields: fields) end)
  end

end

