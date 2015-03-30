defmodule FarmWebSocketHandler do
  @moduledoc """
    This module upgrades an HTTP connection to a WebSocket that manages
    a SmartFarm farm.
  """

  @behaviour :cowboy_http_handler
  @behaviour :cowboy_websocket_handler

  # Requires
  require Poison
  require Record
  require EEx

  # A record to represent the farm ws handler state
  Record.defrecord :state, user_id: nil, farm: nil

  @doc"""
    Initialize the websocket server and set up the inital farm state
  """
  def websocket_init(_any, req, opts) do
    # Get the user id for the signed-in user
    user_id = Keyword.get(opts, :user_id)

    # Load the appropriate farm
    farm_id = Keyword.get(opts, :id)
    case farm_id do
      "new" ->
         farm = Farm.new(user_id)
      _ ->
         farm = Farm.load(farm_id)
    end

    # Send the client the farm
    :erlang.send self(), :farm

    req = :cowboy_req.compact req
    format_ok req, state(farm: farm, user_id: user_id)
  end


  @doc """ 
    Handles websocket messages.  These should be JSON strings in the form
    {type: <type>, data: <data>} from:

    type 		| data
    ====================|======
    login		| text
    name  		| text
    description		| text
    location		| text/JSON
    fields		| text/JSON
    save		| none
    logged-in		| text/JSON
    logged-out		| none

  """  
  def websocket_handle({:text, msg}, req, state(user_id: user_id, farm: farm)=state) do
    json = Poison.decode! msg
    case json["type"] do

      # Control messages
      "login" ->
         format_ok(req, state(state, user_id: json["data"]))

      "name" -> 
         Farm.name(farm, json["data"])
         format_ok(req, state)

      "description" ->
         Farm.description(farm, json["data"])
         format_ok(req, state)

      "location" ->
         Farm.location(farm, json["data"]["latitude"], json["data"]["longitude"])
         format_ok(req, state)

      "fields" ->
         Farm.fields(farm, Poison.encode! json["data"])
         format_ok(req, state)

      "save" ->
         if user_id == :undefined do
           format_reply(req, "{\"type\":\"not-logged-in\"}", state)
         else
           if to_string(Farm.user_id(farm)) == to_string(user_id) do
             id = Farm.save(farm)
           else
             id = Farm.clone(farm, user_id)
           end
           format_reply(req, "{\"type\":\"new-id\",\"data\":#{id}}", state)
         end

      "logged-in" ->
          format_ok(req, state(state, user_id: json["data"]["user_id"]))

      "logged-out" ->
          format_ok(req, state(state, user_id: :undefined))

      msg ->
          format_ok(req, state)

    end
  end

  # Default case
  def websocket_handle(_any, req, state) do
    format_ok req, state
  end

  
  @doc """
    Handles info messages.
  """
  def websocket_info(:farm, req, state(farm: farm)=state) do
    farm_data = Poison.decode! Farm.to_json(farm)
    farm_data = Poison.encode! %{type: "farm", data: farm_data}
    format_reply req, farm_data, state
  end

  def websocket_info(_info, req, state) do
    format_ok req, state
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end


  ## This is the HTTP part of the handler. It will only start up
  ## properly, if the request is asking to upgrade the protocol to
  ## WebSocket

  defp not_implemented(req) do
    { :ok, req } = :cowboy_req.reply(501, [], [], req)
    { :shutdown, req, :undefined }
  end

  def init({_any, :http}, req, _opts) do
    case :cowboy_req.header("upgrade", req) do
      {bin, req} when is_binary(bin) ->
        case :cowboy_bstr.to_lower(bin) do
          "websocket" ->
            { id, req } = :cowboy_req.binding(:id, req, nil)
            { user_id, req } = :cowboy_req.cookie(<<"userid">>, req)
            { :upgrade, :protocol, :cowboy_websocket, req, [id: id, user_id: user_id] }
          _ ->
            not_implemented req
        end
      {:undefined, req} ->
        not_implemented req
    end
  end

  def handle(req, _state) do
    not_implemented req
  end

  def terminate(_reason, _req, _state) do
    :ok
  end


  ## Private API

  defp format_ok(req, state) do
    {:ok, req, state, :hibernate}
  end

  defp format_reply(req, reply, state) do
    {:reply, {:text, reply}, req, state, :hibernate}
  end
end
