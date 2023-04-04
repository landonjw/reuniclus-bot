defmodule Reuniclus.EventConsumer.MessageCreate do
  @moduledoc "Handles the `MESSAGE_CREATE` event."

  require Logger
  alias Nostrum.Struct.Message
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.ThreadHelper

  @spec handle(Message.t()) :: :ok | nil
  def handle(msg) do
    Logger.info("Encountered message.")
    unless msg.author.bot do
      channel_id = msg.channel_id
      thread = ThreadBridge.get_thread_from_channel_id(channel_id)
      unless is_nil(thread) or thread.is_newly_created do
        ThreadHelper.lock_thread(thread)
      end
    end
  end
end