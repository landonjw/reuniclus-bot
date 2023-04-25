defmodule Reuniclus.Bridge.ForumBridge do
  @moduledoc "Responsible for CRUD operations on `Forum` entities."
  import Ecto.Query
  import Ecto.Changeset
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

  def change_bump_prevention(forum, state) do
    forum |> change(bump_prevention: state)
  end

  def delete_forum(forum) do
    Repo.delete(forum)
  end
end
