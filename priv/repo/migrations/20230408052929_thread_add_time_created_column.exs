defmodule Reuniclus.Database.Repo.Migrations.ThreadAddTimeCreatedColumn do
  use Ecto.Migration

  def change do
    alter table("thread") do
      add :time_created, :utc_datetime
    end
  end
end
