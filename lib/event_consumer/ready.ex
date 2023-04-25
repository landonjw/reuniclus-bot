defmodule Reuniclus.EventConsumer.Ready do
  alias Reuniclus.Database.Forum
  alias Reuniclus.Bridge.ForumBridge
  alias Reuniclus.Database.Repo
  require Logger

  def handle() do
    config_forum_channels = Application.get_env(:reuniclus, :forum_channels)

    forums = Repo.all(Forum)

    forums
    |> Enum.each(fn forum -> check_for_updates(forum, config_forum_channels) end)

    forum_channel_ids = Enum.map(forums, fn forum -> forum.id end)

    config_forum_channels
    |> Enum.filter(fn config_forum -> !Enum.member?(forum_channel_ids, config_forum[:id]) end)
    |> Enum.each(fn config_forum -> create_forum(config_forum) end)
  end

  defp check_for_updates(forum, config_forum_channels) do
    forum_config =
      Enum.filter(config_forum_channels, fn config_forum -> config_forum.id == forum.id end)
      |> List.first()

    if is_nil(forum_config) do
      Logger.info("Deleting forum with id #{forum.id}")
      Repo.delete(forum)
    else
      forum
      |> ForumBridge.change_bump_prevention(forum_config[:bump_prevention])
      |> Repo.update()
    end
  end

  defp create_forum(forum_config) do
    Logger.info("Creating forum with id #{forum_config[:id]}")

    forum = %Forum{
      id: forum_config[:id],
      bump_prevention: forum_config[:bump_prevention]
    }

    ForumBridge.create_forum(forum)
  end
end
