defmodule DumbIncrementHandler do
  #@behaviour :simple_handler

  require Record
  Record.defrecordp :state, counter: 0, paused: :false

  def init(_any, req) do
    {:ok, timer} = :timer.send_interval 50, :tick
    {:ok, req, state(counter: 0, paused: :false)}
  end

  def stream("reset\n", req, state) do
    {:ok, req, state(state, counter: 0)}
  end

  def stream("pause\n", req, state) do
    {:ok, req, state(state, paused: :true)}
  end

  def stream("resume\n", req, state) do
    {:ok, req, state(state, paused: :false)}
  end

  # Received timer event
  def info(:tick, req, state(counter: counter, paused: :true)) do
    {:reply,
      to_string(counter),
      req,
      state(counter: counter, paused: true)}
  end

  def info(:tick, req, state(counter: counter, paused: :false)) do
    {:reply,
      to_string(counter),
      req,
      state(state, counter: counter+1)}
  end

  def info(_info, req, state) do
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end

