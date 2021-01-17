defmodule JustOne.GameServer do
  @moduledoc """
  A game server process that holds a `Game` struct as its state.
  """

  use GenServer

  require Logger

  @timeout :timer.hours(2)

  # Client (Public) Interface

  @doc """
  Spawns a new game server process registered under the given `game_name`.
  """
  def start_link(game_name) do
    GenServer.start_link(__MODULE__,
                         {game_name},
                         name: via_tuple(game_name))
  end

  def summary(game_name) do
    GenServer.call(via_tuple(game_name), :summary)
  end

  def give_clue(game_name, word, player) do
    GenServer.call(via_tuple(game_name), {:clue, word, player})
  end

  def guess(game_name, word, player) do
    GenServer.call(via_tuple(game_name), {:guess, word, player})
  end


  def next_round(game_name) do
    GenServer.call(via_tuple(game_name), :next)
  end

  def handle_call(:summary, _from, game) do
    {:reply, summarize(game), game, @timeout}
  end


  def handle_call({:clue, word, player}, _from, game) do
    new_game = JustOne.Game.give_clue(game, word, player)

    :ets.insert(:games_table, {my_game_name(), new_game})
    {:reply, summarize(new_game), new_game, @timeout}
  end


  def handle_call({:guess, word, player}, _from, game) do
    new_game = JustOne.Game.guess(game, word, player)

    :ets.insert(:games_table, {my_game_name(), new_game})
    {:reply, summarize(new_game), new_game, @timeout}
  end


  def handle_call(:next, _from, game) do
    new_game = JustOne.Game.next_round(game)

    :ets.insert(:games_table, {my_game_name(), new_game})
    {:reply, summarize(new_game), new_game, @timeout}
  end

  def summarize(game) do
    game
  end

  @doc """
  Returns a tuple used to register and lookup a game server process by name.
  """
  def via_tuple(game_name) do
    {:via, Registry, {JustOne.GameRegistry, game_name}}
  end

  @doc """
  Returns the `pid` of the game server process registered under the
  given `game_name`, or `nil` if no process is registered.
  """
  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  # Server Callbacks

  def init({game_name}) do
    # buzzwords = Bingo.BuzzwordCache.get_buzzwords()

    game =
      case :ets.lookup(:games_table, game_name) do
        [] ->
          game = JustOne.Game.new()
          :ets.insert(:games_table, {game_name, game})
          game

        [{^game_name, game}] ->
          game
    end

    Logger.info("Spawned game server process named '#{game_name}'.")

    {:ok, game, @timeout}
  end


  def handle_info(:timeout, game) do
    {:stop, {:shutdown, :timeout}, game}
  end

  def terminate({:shutdown, :timeout}, _game) do
    :ets.delete(:games_table, my_game_name())
    :ok
  end

  def terminate(_reason, _game) do
    :ok
  end

  defp my_game_name do
    Registry.keys(JustOne.GameRegistry, self()) |> List.first
  end
end
