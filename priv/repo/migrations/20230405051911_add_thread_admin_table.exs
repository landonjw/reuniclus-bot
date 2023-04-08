defmodule Reuniclus.Database.Repo.Migrations.AddThreadAdminTable do
  use Ecto.Migration

  def change do
    create table("threadadmin") do
      add :user_id, :bigint
      add :thread_id, :bigint
    end
  end
end
