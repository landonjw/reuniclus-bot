defmodule Reuniclus.EventConsumer.GuildAvailable do
  @moduledoc "Handles the `GUILD_AVAILABLE` event."
  alias Nostrum.Api
  alias Reuniclus.Database.Thread
  alias Reuniclus.Bridge.ThreadBridge
  require Logger

  def handle(guild) do
    Reuniclus.Commands.register_commands(guild.id)

    forum_channel_ids =
      Application.get_env(:reuniclus, :forum_channels)
      |> Enum.map(fn forum -> forum.id end)

    {:ok, %{:threads => guild_threads}} = Api.list_guild_threads(guild.id)

    Logger.info("Checking for untracked threads")

    guild_threads
    |> Enum.filter(fn channel -> valid_thread_channel?(forum_channel_ids, channel) end)
    |> filter_missing_thread_records()
    |> Enum.each(fn channel -> create_thread(channel) end)
  end

  def valid_thread_channel?(forum_channel_ids, channel) do
    Enum.member?(forum_channel_ids, channel.parent_id)
  end

  def filter_missing_thread_records(channels) do
    channel_ids = Enum.map(channels, fn channel -> channel.id end)
    missing_channel_ids = ThreadBridge.get_channel_ids_without_thread(channel_ids)
    Enum.filter(channels, fn channel -> Enum.member?(missing_channel_ids, channel.id) end)
  end

  def create_thread(channel) do
    thread = %Thread{
      owner_id: channel.owner_id,
      channel_id: channel.id,
      forum_id: channel.parent_id,
      is_locked: false,
      is_newly_created: false
    }

    Logger.info("Creating thread for #{channel.id}")
    ThreadBridge.create_retroactive(thread)
  end
end
