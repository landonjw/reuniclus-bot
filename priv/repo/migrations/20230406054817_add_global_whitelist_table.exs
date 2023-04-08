defmodule Reuniclus.Database.Repo.Migrations.AddGlobalWhitelistTable do
  use Ecto.Migration

  def change do
    create table("globalwhitelist") do
      add :user_id, :bigint
      add :author_id, :bigint
    end
  end
end
