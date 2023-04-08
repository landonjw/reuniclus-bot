defmodule Reuniclus.ThreadAgeFlagger do
  use Task

  require Logger
  alias Reuniclus.Database.Thread
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.Database.Repo
  alias Reuniclus.ThreadHelper
  alias Nostrum.Api

  def start_link(_opts) do
    Logger.info("Starting ThreadAgeFlagger job.")
    Task.start_link(&flag_old_threads/0)
  end

  defp flag_old_threads() do
    receive do
    after
      15_000 ->
        Logger.info("Flagging old threads...")

        get_threads_to_update()
        |> lock_thread_and_remove_bot_messages()
        |> Repo.update_all(set: [is_newly_created: false])

        flag_old_threads()
    end
  end

  defp get_threads_to_update() do
    Thread
    |> ThreadBridge.with_created_time_before(get_new_post_lock_time())
    |> ThreadBridge.with_newly_created_state(true)
  end

  defp lock_thread_and_remove_bot_messages(thread_query) do
    thread_query
    |> Repo.all()
    |> Enum.each(fn thread ->
      delete_bot_messages(thread.channel_id)
      ThreadHelper.lock_thread(thread)
    end)

    thread_query
  end

  defp delete_bot_messages(channel_id) do
    {:ok, messages} = Api.get_channel_messages(channel_id, 100)
    Enum.each(messages, fn message -> delete_message_if_bot(message) end)
  end

  defp delete_message_if_bot(message) do
    if message.author.bot do
      Logger.info("Deleting bot message...")
      Api.delete_message(message)
    end
  end

  defp get_new_post_lock_time() do
    new_post_time_out =
      Application.get_env(:reuniclus, BumpPrevention)[:new_post_lock_timeout_minutes]

    DateTime.utc_now()
    |> Timex.shift(minutes: -new_post_time_out)
  end
end
