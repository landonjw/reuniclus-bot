defmodule Reuniclus.Database.Thread do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}
  schema "thread" do
    field :owner_id, :integer
    field :channel_id, :integer
    field :last_update, :utc_datetime
    field :is_locked, :boolean
    field :is_newly_created, :boolean
  end
end