defmodule Reuniclus.Database.Repo.Migrations.AddThreadTable do
  use Ecto.Migration

  def change do
    create table("thread") do
      add :owner_id, :bigint
      add :channel_id, :bigint
      add :last_update, :utc_datetime
      add :is_locked, :boolean
      add :is_newly_created, :boolean
    end
  end
end