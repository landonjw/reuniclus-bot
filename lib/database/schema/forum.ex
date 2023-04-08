defmodule Reuniclus.Database.Forum do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}
  schema "forum" do
    field(:bump_prevention, :boolean)
  end
end
