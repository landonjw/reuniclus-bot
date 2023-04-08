defmodule Reuniclus.Database.Repo.Migrations.AddForumTable do
  use Ecto.Migration

  def change do
    create table("forum") do
      add :bump_prevention, :boolean
    end
  end
end
