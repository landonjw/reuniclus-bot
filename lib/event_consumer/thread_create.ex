defmodule Reuniclus.EventConsumer.ThreadCreate do
  @moduledoc false

  require Logger
  alias Nostrum.Api
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.Database.Thread
  alias Reuniclus.Database.Repo
  alias Reuniclus.Bridge.ForumBridge
  alias Reuniclus.Database.Forum

  def handle(channel) do
    if is_forum_thread(channel) and channel.newly_created do
      Logger.info("Creating new thread for channel id #{channel.id}")

      thread = %Thread{
        owner_id: channel.owner_id,
        channel_id: channel.id,
        is_locked: false,
        is_newly_created: true
      }

      ThreadBridge.create(thread)

      forum = Forum |> ForumBridge.with_id(channel.parent_id) |> Repo.one()

      if forum.bump_prevention do
        spawn(fn -> send_bot_message(channel) end)
      end
    end
  end

  defp send_bot_message(channel) do
    Process.sleep(1000)

    posting_cool_down =
      Application.get_env(:reuniclus, BumpPrevention)[:forum_lock_duration_minutes]

    new_post_lock_timeout =
      Application.get_env(:reuniclus, BumpPrevention)[:new_post_lock_timeout_minutes]

    message =
      "Each time a new post is created, this thread will lock for #{posting_cool_down} minute(s).\n" <>
        "This thread will lock and this message will be deleted in #{new_post_lock_timeout} minute(s)."

    Api.create_message(channel.id, message)
  end

  defp is_forum_thread(channel) do
    Application.fetch_env!(:reuniclus, :forum_channels)
    |> Enum.filter(fn forum_channel -> forum_channel.id == channel.parent_id end)
    |> Enum.empty?()
    |> Kernel.not()
  end
end
