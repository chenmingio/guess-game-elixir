defmodule JustOne.Player do

  @enforce_keys [:name, :color]
  defstruct [:name, :color]

  def new(name, color) do
    %JustOne.Player{name: name, color: color}
  end
end
