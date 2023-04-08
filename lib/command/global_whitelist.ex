defmodule Reuniclus.Command.GlobalWhitelist do
  import Reuniclus.InteractionHelper,
    only: [respond_message: 2, respond_embed: 3, has_argument: 2]

  alias Reuniclus.Bridge.GlobalWhitelistBridge
  alias Reuniclus.Database.GlobalWhitelist
  alias Reuniclus.Database.Repo

  def command() do
    %{
      name: "globalwhitelist",
      type: 1,
      description: "Allows a user to post in any of your forum threads",
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
            }
          ]
        },
        %{
          name: "list",
          description: "Lists all users in your global whitelist",
          type: 1
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

    global_whitelists =
      GlobalWhitelist
      |> GlobalWhitelistBridge.with_author_id(sender_id)
      |> Repo.all()

    if Enum.empty?(global_whitelists) do
      respond_message(interaction, "You do not currently have any globally whitelisted users")
    else
      embed_content =
        global_whitelists
        |> Enum.map(&create_user_tag_listing/1)
        |> Enum.join("\n")

      respond_embed(interaction, "Globally whitelisted users", embed_content)
    end
  end

  def handle_whitelist_action("add", interaction) do
    sender_id = interaction.user.id
    [%{name: "user", value: target_user_id}] = hd(interaction.data.options).options

    if is_target_author?(interaction, target_user_id) do
      respond_message(interaction, "You cannot use this command on yourself.")
    else
      user_already_whitelisted? =
        GlobalWhitelist
        |> GlobalWhitelistBridge.with_author_id(sender_id)
        |> GlobalWhitelistBridge.with_user_id(target_user_id)
        |> Repo.exists?()

      if user_already_whitelisted? do
        respond_message(interaction, "User is already globally whitelisted.")
      else
        GlobalWhitelistBridge.create(%GlobalWhitelist{author_id: sender_id, user_id: target_user_id})
        respond_message(interaction, "User added to your global whitelist!")
      end
    end
  end

  def handle_whitelist_action("remove", interaction) do
    sender_id = interaction.user.id
    [%{name: "user", value: target_user_id}] = hd(interaction.data.options).options

    if is_target_author?(interaction, target_user_id) do
      respond_message(interaction, "You cannot use this command on yourself.")
    else
      global_whitelist =
        GlobalWhitelist
        |> GlobalWhitelistBridge.with_author_id(sender_id)
        |> GlobalWhitelistBridge.with_user_id(target_user_id)
        |> Repo.one()

      if is_nil(global_whitelist) do
        respond_message(interaction, "User is not currently globally whitelisted.")
      else
        GlobalWhitelistBridge.delete(global_whitelist)
        respond_message(interaction, "User removed from your global whitelist!")
      end
    end
  end

  defp create_user_tag_listing(global_whitelist) do
    "• <@#{to_string(global_whitelist.user_id)}>"
  end

  defp is_target_author?(interaction, target_user_id) do
    interaction.user.id == target_user_id
  end
end
