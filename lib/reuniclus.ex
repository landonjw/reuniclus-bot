defmodule Reuniclus do
  @moduledoc """
  Documentation for `Reuniclus`.
  """

  use Application

  @impl true
  @spec start(
          Application.start_type(),
          term()
        ) :: {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, term()}
  def start(_type, _args) do
    children = [
      Reuniclus.EventDispatcher.Supervisor,
      Reuniclus.Database.Repo,
      {Cachex, name: :reuniclus_threads},
      Reuniclus.ThreadUnlocker,
      Reuniclus.ThreadAgeFlagger
    ]

    options = [strategy: :rest_for_one, name: Reuniclus.Supervisor]
    Supervisor.start_link(children, options)
  end
end
