defmodule Reuniclus.EventConsumer.ThreadCreate do
  @moduledoc false

  require Logger
  alias Nostrum.Api
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.ThreadHelper
  alias Reuniclus.Database.Thread

  def handle(channel) do
    if is_server_listing_thread(channel) and channel.newly_created do
      spawn(fn -> send_bot_message(channel) end)
      thread = %Thread{owner_id: channel.owner_id, channel_id: channel.id, is_locked: false, is_newly_created: true}
      ThreadBridge.create_thread(thread)
      spawn(fn -> lock_thread_and_delete_message(channel) end)
    end
  end

  defp send_bot_message(channel) do
    Process.sleep(1000)
    posting_cool_down = Application.fetch_env!(:reuniclus, :unlock_interval_minutes)
    bot_lock_cool_down = Application.fetch_env!(:reuniclus, :bot_lock_cool_down_minutes)
    message = "Each time a new post is created, this thread will lock for #{posting_cool_down} minute(s).\n" <>
              "This thread will lock and this message will be deleted in #{bot_lock_cool_down} minute(s)."
    Api.create_message(channel.id, message)
  end

  defp is_server_listing_thread(channel) do
    channel.parent_id == Application.fetch_env!(:reuniclus, :server_listing_channel_id)
  end

  defp lock_thread_and_delete_message(channel) do
    bot_lock_cool_down = Application.fetch_env!(:reuniclus, :bot_lock_cool_down_minutes)
    Process.sleep(bot_lock_cool_down * 60000)
    thread = ThreadBridge.get_thread_from_channel_id(channel.id)
    ThreadBridge.flag_thread_old(thread)
    ThreadHelper.lock_thread(thread)
    delete_bot_message(channel.id)
  end

  defp delete_bot_message(channel_id) do
    {:ok, messages} = Api.get_channel_messages(channel_id, 50)
    Enum.each(messages, fn message -> delete_message_if_bot(message) end)
  end

  defp delete_message_if_bot(message) do
    if message.author.bot do
      Logger.info("Deleting bot message...")
      Api.delete_message(message)
    end
  end
end