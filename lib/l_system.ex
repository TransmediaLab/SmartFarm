defmodule LSystem do
  
  require Record

  Record.defrecordp :turtle, x: 0, y: 0, facing: :math.pi()/2, step: 10, angle: :math.pi()/12, stack: []

  def render(cmds) do
    renderSVG(String.codepoints(cmds), "<path d=\" M 0 0 ", turtle())
  end

  def renderSVG([], svg, turtle) do
    svg = svg <> " z\" />"
  end

  def renderSVG([command|tail], svg, tstate) do
    case command do
      "+" ->
        turtle(facing: facing, angle: angle) = tstate
        facing = facing + angle
        tstate = turtle(tstate, facing: facing)
      "-" ->
        turtle(facing: facing, angle: angle) = tstate
        facing = facing - angle
        tstate = turtle(tstate, facing: facing)
      "[" -> 
        turtle(x: x, y: y, facing: facing, stack: stack) = tstate
        state = {x, y, facing}
        tstate = turtle(tstate, stack: [state | stack])
      "]" ->
        turtle(stack: stack) = tstate
        [{x, y, facing}|tail] = stack
        tstate = turtle(tstate, x: x, y: y, facing: facing)
        svg = svg <> "\" z/><path d=\" M #{x} #{y} "
      _ ->
        turtle(x: x, y: y, facing: facing, step: step) = tstate
        x = x + step * :math.cos(facing)
        y = y + step * :math.sin(facing) 
        svg = svg <> "L  #{x} #{y} "
        tstate = turtle(tstate, x: x, y: y) 
    end
    renderSVG(tail, svg, tstate)
  end

  
end
