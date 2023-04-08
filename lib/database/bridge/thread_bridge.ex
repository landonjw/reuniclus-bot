defmodule Reuniclus.Bridge.ThreadBridge do
  @moduledoc "Responsible for CRUD operations on `Thread` entities."
  import Ecto.Query
  import Ecto.Changeset
  alias Reuniclus.Database.ThreadWhitelist
  alias Reuniclus.Database.Repo

  def create(thread) do
    Repo.insert(%{thread | is_newly_created: true, last_update: get_utc_now(), time_created: get_utc_now()})
  end

  def with_id(query, id) do
    query
    |> where([thread], thread.id == ^id)
  end

  def with_channel_id(query, channel_id) do
    query
    |> where([thread], thread.channel_id == ^channel_id)
  end

  def with_owner_id(query, owner_id) do
    query
    |> where([thread], thread.owner_id == ^owner_id)
  end

  def without_user_whitelisted(query, user_id) do
    query
    |> join(:left, [thread], thread_whitelist in ThreadWhitelist,
      on: thread.id == thread_whitelist.thread_id
    )
    |> where(
      [thread, thread_whitelist],
      is_nil(thread_whitelist.id) and thread.owner_id != ^user_id
    )
    |> select([thread, thread_whitelist], thread)
  end

  def with_user_whitelisted(query, user_id) do
    query
    |> join(:inner, [thread], thread_whitelist in ThreadWhitelist,
      on:
        thread.id == thread_whitelist.thread_id and
          (thread_whitelist.user_id == ^user_id or
             thread.owner_id == ^user_id)
    )
    |> select([thread, thread_whitelist], thread)
  end

  def with_lock_state(query, state) do
    query |> where([thread], thread.is_locked == ^state)
  end

  def with_last_update_before(query, date) do
    query |> where([thread], thread.last_update < ^date)
  end

  def with_created_time_before(query, date) do
    query |> where([thread], thread.time_created < ^date)
  end

  def with_newly_created_state(query, state) do
    query |> where([thread], thread.is_newly_created == ^state)
  end

  def lock_thread(thread) do
    thread |> change(is_locked: true, last_update: get_utc_now())
  end

  def unlock_thread(thread) do
    thread |> change(is_locked: false)
  end

  def flag_thread_old(thread) do
    thread |> change(is_newly_created: false)
  end

  def delete(thread) do
    Repo.delete(thread)
  end

  defp get_utc_now() do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
