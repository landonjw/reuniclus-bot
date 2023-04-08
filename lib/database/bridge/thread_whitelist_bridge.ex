defmodule Reuniclus.Bridge.ThreadWhitelistBridge do
  @moduledoc "Responsible for CRUD operations on Forum entities."
  import Ecto.Query
  alias Reuniclus.Database.Thread
  alias Reuniclus.Database.Repo

  def create(thread_whitelist) do
    Repo.insert(thread_whitelist)
  end

  def with_thread_id(query, thread_id) do
    query |> where([thread_whitelist], thread_whitelist.thread_id == ^thread_id)
  end

  def with_user_id(query, user_id) do
    query |> where([thread_whitelist], thread_whitelist.user_id == ^user_id)
  end

  def with_thread_owner_id(query, thread_owner_id) do
    query
    |> join(:inner, [thread_whitelist], thread in Thread, on: thread_whitelist.thread_id == thread.id)
    |> where([thread_whitelist, thread], thread.owner_id == ^thread_owner_id)
    |> select([thread_whitelist, thread], thread_whitelist)
  end

  def delete(thread_whitelist) do
    Repo.delete(thread_whitelist)
  end
end
