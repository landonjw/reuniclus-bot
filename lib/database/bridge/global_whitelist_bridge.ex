defmodule Reuniclus.Bridge.GlobalWhitelistBridge do
  import Ecto.Query
  alias Reuniclus.Database.Repo

  def create(global_whitelist) do
    Repo.insert(global_whitelist)
  end

  def with_user_id(query, user_id) do
    query |> where([global_whitelist], global_whitelist.user_id == ^user_id)
  end

  def with_author_id(query, author_id) do
    query |> where([global_whitelist], global_whitelist.author_id == ^author_id)
  end

  def delete(global_whitelist) do
    Repo.delete(global_whitelist)
  end
end
