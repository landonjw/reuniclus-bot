defmodule Reuniclus.Database.Repo.Migrations.AddThreadDeleteCascade do
  use Ecto.Migration

  def change do
    drop constraint("thread", :thread_forum_id_fkey)

    alter table("thread") do
      modify :forum_id, references("forum", on_delete: :delete_all)
    end
  end
end
