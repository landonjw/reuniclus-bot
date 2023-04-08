defmodule Reuniclus.Database.Repo.Migrations.RenameThreadadminToThreadwhitelist do
  use Ecto.Migration

  def change do
    rename table("threadadmin"), to: table("threadwhitelist")
  end
end
