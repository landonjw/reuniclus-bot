defmodule Reuniclus.EventConsumer.MessageCreate do
  @moduledoc "Handles the `MESSAGE_CREATE` event."

  require Logger
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.Bridge.ThreadWhitelistBridge
  alias Reuniclus.ThreadHelper
  alias Reuniclus.Database.Thread
  alias Reuniclus.Database.ThreadWhitelist
  alias Reuniclus.Database.Forum
  alias Reuniclus.Bridge.ForumBridge
  alias Reuniclus.Database.Repo
  alias Reuniclus.Database.GlobalWhitelist
  alias Reuniclus.Bridge.GlobalWhitelistBridge
  alias Nostrum.Api

  def handle(msg) do
    unless msg.author.bot do
      channel_id = msg.channel_id

      thread = get_thread(channel_id)

      unless is_nil(thread) do
        {:ok, channel} = Api.get_channel(channel_id)

        if is_forum_bump_prevented?(channel.parent_id) and thread.is_newly_created == false do
          ThreadHelper.lock_thread(thread)
        end

        user_authorized = is_user_authorized?(msg.author.id, thread)

        unless user_authorized do
          Logger.info("Deleting unauthorized user's message.")
          Api.delete_message(msg)
        end
      end
    end
  end

  defp get_thread(channel_id) do
    {:ok, key_exists?} = Cachex.exists?(:reuniclus_threads, channel_id)

    if key_exists? do
      Logger.info("Returning cached thread")
      {:ok, thread} = Cachex.get(:reuniclus_threads, channel_id)
      thread
    else
      Logger.info("Fetching thread from database")

      thread =
        Thread
        |> ThreadBridge.with_channel_id(channel_id)
        |> Repo.one()

      Cachex.put(:reuniclus_threads, channel_id, thread, ttl: :timer.seconds(60))
      thread
    end
  end

  defp is_forum_bump_prevented?(forum_id) do
    Forum
    |> ForumBridge.with_id(forum_id)
    |> ForumBridge.with_bump_prevention()
    |> Repo.exists?()
  end

  defp is_user_authorized?(sender_id, thread) do
    cond do
      is_nil(thread) -> false
      thread.owner_id == sender_id -> true
      true -> is_user_whitelisted?(sender_id, thread)
    end
  end

  defp is_user_whitelisted?(user_id, thread) do
    is_user_global_whitelisted?(user_id, thread) or is_user_thread_whitelisted?(user_id, thread)
  end

  defp is_user_global_whitelisted?(user_id, thread) do
    thread_owner_id =
      Thread
      |> ThreadBridge.with_id(thread.id)
      |> Repo.one()
      |> Map.get(:owner_id)

    GlobalWhitelist
    |> GlobalWhitelistBridge.with_user_id(user_id)
    |> GlobalWhitelistBridge.with_author_id(thread_owner_id)
    |> Repo.exists?()
  end

  defp is_user_thread_whitelisted?(user_id, thread) do
    ThreadWhitelist
    |> ThreadWhitelistBridge.with_thread_id(thread.id)
    |> ThreadWhitelistBridge.with_user_id(user_id)
    |> Repo.exists?()
  end
end
