defmodule Reuniclus.EventConsumer.GuildAuditLogEntryCreate do
  alias Reuniclus.Database.Thread
  alias Reuniclus.Database.ThreadWhitelist
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.Bridge.ThreadWhitelistBridge
  alias Reuniclus.Database.Repo
  require Logger

  def handle(audit_log_entry) do
    if audit_log_entry.action_type == 112 do
      channel_id = audit_log_entry.target_id
      delete_thread(channel_id)
    end
  end

  defp delete_thread(channel_id) do
    thread =
      Thread
      |> ThreadBridge.with_channel_id(channel_id)
      |> Repo.one()

    unless is_nil(thread) do
      Logger.info("Deleting thread for channel id #{channel_id}")
      delete_thread_whitelists(thread)
      Repo.delete(thread)
    end
  end

  defp delete_thread_whitelists(thread) do
    ThreadWhitelist
    |> ThreadWhitelistBridge.with_thread_id(thread.id)
    |> Repo.delete_all()
  end
end
