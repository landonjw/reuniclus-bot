defmodule Reuniclus.Bridge.ThreadBridge do
  @moduledoc "Fetches a `Thread` from some store."
  import Ecto.Query
  import Ecto.Changeset
  alias Reuniclus.Database.Thread
  alias Reuniclus.Database.Repo

  def create_thread(thread) do
    Repo.insert(%{thread | last_update: get_utc_now()})
  end

  def get_threads_to_unlock() do
    Thread
    |> where([thread], thread.is_locked and thread.last_update < ^get_cool_down_time())
    |> Repo.all()
  end

  def get_thread_from_channel_id(channel_id) do
    Thread
    |> where([thread], thread.channel_id == ^channel_id)
    |> Repo.one()
  end

  def lock_thread(thread) do
    thread
    |> change(is_locked: true, last_update: get_utc_now())
    |> Repo.update()
  end

  def unlock_thread(thread) do
    thread
    |> change(is_locked: false)
    |> Repo.update()
  end

  def flag_thread_old(thread) do
    thread
    |> change(is_newly_created: false)
    |> Repo.update()
  end

  def delete_thread(thread) do
    Repo.delete(thread)
  end

  defp get_utc_now() do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end

  defp get_cool_down_time() do
    cool_down = Application.fetch_env!(:reuniclus, :unlock_interval_minutes)
    DateTime.utc_now()
    |> Timex.shift(minutes: -cool_down)
  end
end