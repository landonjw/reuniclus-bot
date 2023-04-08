defmodule Reuniclus.Database.GlobalWhitelist do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}
  schema "globalwhitelist" do
    field(:user_id, :integer)
    field(:author_id, :integer)
  end
end
