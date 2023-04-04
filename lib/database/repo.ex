defmodule Reuniclus.Database.Repo do
  use Ecto.Repo,
    otp_app: :reuniclus,
    adapter: Ecto.Adapters.Postgres
end
