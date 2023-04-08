defmodule Reuniclus.Bridge.ForumBridge do
  @moduledoc "Responsible for CRUD operations on `Forum` entities."
  import Ecto.Query
  alias Reuniclus.Database.Repo

  def create_forum(forum) do
    Repo.insert(forum)
  end

  def with_id(query, forum_id) do
    query
    |> where([forum], forum.id == ^forum_id)
  end

  def with_bump_prevention(query) do
    query
    |> where([forum], forum.bump_prevention == true)
  end

  def delete_forum(forum) do
    Repo.delete(forum)
  end
end
