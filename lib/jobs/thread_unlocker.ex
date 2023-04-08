defmodule Reuniclus.ThreadUnlocker do
  @moduledoc false
  use Task

  require Logger
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.ThreadHelper
  alias Reuniclus.Database.Thread
  alias Reuniclus.Database.Repo

  def start_link(_opts) do
    Logger.info("Starting ThreadUnlocker job.")
    Task.start_link(&unlock_valid_threads/0)
  end

  defp unlock_valid_threads() do
    receive do
    after
      15_000 ->
        Logger.info("Unlocking valid threads...")

        Thread
        |> ThreadBridge.with_lock_state(true)
        |> ThreadBridge.with_last_update_before(get_cool_down_time())
        |> Repo.all()
        |> Enum.each(fn thread -> ThreadHelper.unlock_thread(thread) end)

        unlock_valid_threads()
    end
  end

  defp get_cool_down_time() do
    cool_down = Application.get_env(:reuniclus, BumpPrevention)[:forum_lock_duration_minutes]

    DateTime.utc_now()
    |> Timex.shift(minutes: -cool_down)
  end
end
