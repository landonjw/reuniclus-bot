defmodule Reuniclus.Command.Whitelist do
  @moduledoc "Handles the `whitelist` command."
  import Reuniclus.InteractionHelper,
    only: [respond_message: 2, respond_embed: 3, has_argument: 2]

  alias Reuniclus.Bridge.ThreadWhitelistBridge
  alias Reuniclus.Database.ThreadWhitelist
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.Database.Thread
  alias Reuniclus.Database.Repo
  import Ecto.Query
  require Logger

  def command() do
    %{
      name: "whitelist",
      type: 1,
      description: "Allows a user to post in one of your forum threads",
      options: [
        %{
          name: "add",
          description: "Adds a user to your global whitelist",
          type: 1,
          options: [
            %{
              name: "user",
              description: "The user to add",
              type: 6,
              required: true
            },
            %{
              name: "channel",
              description: "The channel they will be whitelisted in",
              type: 7,
              required: true
            }
          ]
        },
        %{
          name: "remove",
          description: "Removes a user from your global whitelist",
          type: 1,
          options: [
            %{
              name: "user",
              description: "The user to remove",
              type: 6,
              required: true
            },
            %{
              name: "channel",
              description: "The channel to remove whitelist from",
              type: 7,
              required: true
            }
          ]
        },
        %{
          name: "list",
          description: "Lists all users in your global whitelist",
          type: 1,
          options: [
            %{
              name: "channel",
              description: "The channel to list users for",
              type: 7,
              required: false
            }
          ]
        }
      ]
    }
  end

  def handle(interaction) do
    cond do
      has_argument(interaction, "list") ->
        handle_whitelist_action("list", interaction)

      has_argument(interaction, "add") ->
        handle_whitelist_action("add", interaction)

      has_argument(interaction, "remove") ->
        handle_whitelist_action("remove", interaction)
    end
  end

  def handle_whitelist_action("list", interaction) do
    sender_id = interaction.user.id
    list_options = hd(interaction.data.options).options

    thread_whitelists =
      case list_options do
        [%{name: "channel", value: channel_id}] -> get_thread_whitelists(sender_id, channel_id)
        [] -> get_thread_whitelists(sender_id)
      end

    if Enum.empty?(thread_whitelists) do
      respond_message(interaction, "You do not currently have any whitelisted users ")
    else
      embed_content =
        thread_whitelists
        |> Enum.map(&create_thread_whitelist_item/1)
        |> Enum.join("\n")

      respond_embed(interaction, "Thread whitelisted users", embed_content)
    end
  end

  def handle_whitelist_action("add", interaction) do
    sender_id = interaction.user.id

    [%{name: "user", value: target_user_id}, %{name: "channel", value: channel_id}] =
      hd(interaction.data.options).options

    thread =
      Thread
      |> ThreadBridge.with_channel_id(channel_id)
      |> ThreadBridge.with_owner_id(sender_id)
      |> Repo.one()

    if is_nil(thread) do
      respond_message(interaction, "You do not own the requested thread")
    else
      user_already_whitelisted? =
        ThreadWhitelist
        |> ThreadWhitelistBridge.with_thread_id(thread.id)
        |> ThreadWhitelistBridge.with_user_id(target_user_id)
        |> Repo.exists?()

      if user_already_whitelisted? do
        respond_message(interaction, "User is already whitelisted in this thread")
      else
        ThreadWhitelistBridge.create(%ThreadWhitelist{
          user_id: target_user_id,
          thread_id: thread.id
        })

        respond_message(interaction, "User added to the thread's whitelist!")
      end
    end
  end

  def handle_whitelist_action("remove", interaction) do
    sender_id = interaction.user.id

    [%{name: "user", value: target_user_id}, %{name: "channel", value: channel_id}] =
      hd(interaction.data.options).options

    thread =
      Thread
      |> ThreadBridge.with_channel_id(channel_id)
      |> ThreadBridge.with_owner_id(sender_id)
      |> Repo.one()

    if is_nil(thread) do
      respond_message(interaction, "You do not own the requested thread")
    else
      user_whitelist =
        ThreadWhitelist
        |> ThreadWhitelistBridge.with_thread_id(thread.id)
        |> ThreadWhitelistBridge.with_user_id(target_user_id)
        |> Repo.one()

      IO.inspect(user_whitelist)

      if is_nil(user_whitelist) do
        respond_message(interaction, "User is not whitelisted in this thread")
      else
        ThreadWhitelistBridge.delete(user_whitelist)

        respond_message(interaction, "User added to the thread's whitelist!")
      end
    end
  end

  defp get_thread_whitelists(sender_id, channel_id) do
    Thread
    |> join(:inner, [thread], thread_whitelist in ThreadWhitelist,
      on: thread_whitelist.thread_id == thread.id
    )
    |> where(
      [thread, thread_whitelist],
      thread.owner_id == ^sender_id and thread.channel_id == ^channel_id
    )
    |> select([thread, thread_whitelist], [thread.channel_id, thread_whitelist.user_id])
    |> Repo.all()
  end

  defp get_thread_whitelists(sender_id) do
    Thread
    |> join(:inner, [thread], thread_whitelist in ThreadWhitelist,
      on: thread_whitelist.thread_id == thread.id
    )
    |> where([thread, thread_whitelist], thread.owner_id == ^sender_id)
    |> select([thread, thread_whitelist], [thread.channel_id, thread_whitelist.user_id])
    |> Repo.all()
  end

  defp create_thread_whitelist_item([channel_id, user_id]) do
    "• <@#{to_string(user_id)}> - <##{to_string(channel_id)}>"
  end
end
