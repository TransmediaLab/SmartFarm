defmodule LSystem do
  @moduledoc """
    Defines methods for creating, iterating, and rendering L-Systems
  """  

  require Record

  Record.defrecordp :turtle, x: 0, y: 0, facing: :math.pi()/2, step: 10, angle: :math.pi()/12, stack: []

  @doc """
    Defines an Lsystem from the supplied axiom and rules
  """
  def define(axiom, rules) do
    {:lsystem, axiom, rules}
  end


  @doc """
    Lindenmayer's original L-System for modeling algae growth
  """
  def algae do
    {:lsystem, <<"A">>, fn <<"A",tail::binary>> -> {<<"AB">>,tail}; <<"B",tail::binary>> -> {<<"A">>,tail}; <<symbol,tail::binary>> -> {<<symbol>>,tail} end}
  end


  @doc """
    L-System for a Pythagoras Tree
  """
  def pythagoras_tree do
    {:lsystem, <<"0">>, fn <<"1",tail::binary>> -> {<<"11">>,tail}; <<"0",tail::binary>> -> {<<"1[-0]+0">>,tail}; <<symbol,tail::binary>> -> {<<symbol>>,tail} end}
  end


  @doc """
    Returns the result of applying *count* iterations to the *lsystem*
  """
  def iterate({:lsystem, axiom, rules}=lsystem, count) do
    recurse(axiom, count, <<>>, rules)
  end


  @doc """
    Renders as an SVG snippet the product of the supplied *lsystem* 
    after applying *count* recursions.  
    Rendering is done by tracing the path of a virtual _turtle_, starting 
    from *point*.  Symbols in the string act as commands to the turtle:
    symbol | command
       +   | turn clockwise by *angle*
       -   | turn counterclockwise by *angle*
       [   | push the current turtle state to the stack
       ]   | restore the last turtle state pushed to the stack
      any  | move forward by *distance*
  """
  def render(lsystem, count, angle, distance, offset \\ {:point, 0, 0}) do
    # Generate final symbols
    symbols = iterate(lsystem, count)

    # Generate SVG snippet from the symbols
    {:point, x, y} = offset
    renderSVG(symbols, [], turtle(x: x, y: y, angle: angle, step: distance))
  end


  # Helper methods for iterating an L-System

  defp recurse(input, 0, _, _) do
    input
  end

  defp recurse(<<>>, recursions, output, mapping) do
    recurse(output, recursions - 1, <<>>, mapping)
  end

  defp recurse(symbols, recursions, output, mapping) do
    {product, tail} = mapping.(symbols)
    recurse(tail, recursions, output <> product, mapping)
  end


  # Helper methods for carrying out turtle graphics with an L-System

  def renderSVG(symbols, [], state) do
    renderSVG(symbols, [<<"M0,0">>], state)
  end

  def renderSVG(<<>>, paths, state) do
    paths
  end

  def renderSVG(<<command::utf8, commands::binary>>, [path|paths], state) do
    case command do
      ?+ ->
        turtle(facing: facing, angle: angle) = state
        state = turtle(state, facing: facing + angle)
      ?- ->
        turtle(facing: facing, angle: angle) = state
        state = turtle(state, facing: facing - angle)
      ?[ -> 
        turtle(x: x, y: y, facing: facing, stack: stack) = state
        state = turtle(state, stack: [{x, y, facing} | stack])
      ?] ->
        turtle(stack: [{x,y,facing} | tail]) = state
        paths = [path|paths]
        path = <<"M#{round(x)},#{round(-y)}">>
        state = turtle(state, x: x, y: y, facing: facing, stack: tail)
      _ ->
        turtle(x: x, y: y, facing: facing, step: step) = state
        x = x + step * :math.cos(facing)
        y = y + step * :math.sin(facing) 
        path = path <> <<"L#{round(x)},-#{round(y)}">>
        state = turtle(state, x: x, y: y) 
    end
    renderSVG(commands, [path|paths], state)
  end

end

