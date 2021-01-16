defmodule Guess do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Guess.GameRegistry},
      Guess.GameSupervisor
    ]
    :ets.new(:games_table, [:public, :named_table])

    opts = [strategy: :one_for_one, name: Guess.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
