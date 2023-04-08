defmodule Reuniclus.EventConsumer.Ready do
  alias Reuniclus.Database.Forum
  alias Reuniclus.Database.Repo

  def handle() do
    Forum
    |> Repo.delete_all()

    Application.get_env(:reuniclus, :forum_channels)
    |> Enum.each(fn forum -> Repo.insert(create_forum(forum)) end)
  end

  defp create_forum(forum) do
    %Forum{
      id: forum[:id],
      bump_prevention: forum[:bump_prevention]
    }
  end
end
