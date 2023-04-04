defmodule Reuniclus.ThreadHelper do
  @moduledoc false
  alias Nostrum.Api
  alias Reuniclus.Bridge.ThreadBridge

  def lock_thread(thread) do
    ThreadBridge.lock_thread(thread)
    Api.modify_channel(thread.channel_id, %{locked: true})
  end

  def unlock_thread(thread) do
    ThreadBridge.unlock_thread(thread)
    Api.modify_channel(thread.channel_id, %{locked: false})
  end
end