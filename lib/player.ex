defmodule Guess.Player do

  @enforce_keys [:name, :color]
  defstruct [:name, :color]

  def new(name, color) do
    %Guess.Player{name: name, color: color}
  end
end
