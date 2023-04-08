defmodule Reuniclus.Database.Repo.Migrations.AddThreadForumRelationship do
  use Ecto.Migration

  def change do
    alter table("thread") do
      add :forum_id, references("forum")
    end
  end
end
