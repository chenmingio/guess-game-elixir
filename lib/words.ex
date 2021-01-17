defmodule JustOne.Words do

  def read_words do
    "../data/emotion-words.txt"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split("\n", trim: true)
  end

end
