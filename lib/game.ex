defmodule JustOne.Game do

  @max_try 3

  defstruct answer: nil, scores: %{}, clues: [], trys: 0, status: "on-going"

  alias JustOne.{Game, Words, Clue}


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

  def give_clue(game, clue, player) do
    new_clues = [Clue.new(clue, player) | game.clues]
    %{game | clues: new_clues}
  end


def guess(game, word, player) do
  case (word === game.answer && game.status === "on-going") do
    true -> %{game | status: "success"} |> update_scores(player)
    false -> case (game.trys + 1 <= @max_try) do
      true -> %{game | trys: game.trys + 1}
      false -> %{game | status: "failed"}
    end
  end
end

def update_scores(game, player) do
  new_scores = Map.update(game.scores, player.name, 1, &(&1 + 1))
  %{game | scores: new_scores}
end


def next_round(game) do
  new_game = new()
  %{new_game | scores: game.scores}
end

end
