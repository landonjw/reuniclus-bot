defmodule Reuniclus.ThreadUnlocker do
  @moduledoc false
  use GenServer

  require Logger
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.ThreadHelper
  alias Nostrum.Api

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    Logger.info("Starting ThreadUnlocker job.")
    wait_time = Application.fetch_env!(:reuniclus, :unlocker_poll_rate_minutes)
    unlock_valid_threads(wait_time)
  end

  defp unlock_valid_threads(wait_time) do
    Logger.info("Unlocking valid threads...")
    threads = ThreadBridge.get_threads_to_unlock()
    Enum.each(threads, fn thread -> ThreadHelper.unlock_thread(thread) end)
    Process.sleep(wait_time * 60000)
    Logger.info("Valid threads unlocked.")
    unlock_valid_threads(wait_time)
  end
end