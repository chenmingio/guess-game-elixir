defmodule Guess.Game do

  defstruct answer: nil, scores: %{}

  alias Guess.{Game, Words}

  def new() do
    words = Words.read_words()
    Game.new(words)
  end

  def new(words) do
    answer =
      words
      |> Enum.random()

    %Game{answer: answer}
  end

end
