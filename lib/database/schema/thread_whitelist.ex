defmodule Reuniclus.Database.ThreadWhitelist do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}
  schema "threadwhitelist" do
    field(:user_id, :integer)
    field(:thread_id, :integer)
  end
end
