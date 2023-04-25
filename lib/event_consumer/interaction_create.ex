defmodule Reuniclus.EventConsumer.InteractionCreate do
  @moduledoc "Handles the `INTERACTION_CREATE` event."

  require Logger
  alias Nostrum.Struct.Interaction

  alias Reuniclus.Command.{
    Whitelist,
    GlobalWhitelist
  }

  def handle(%Interaction{data: %{name: "whitelist"}} = interaction) do
    Whitelist.handle(interaction)
  end

  def handle(%Interaction{data: %{name: "globalwhitelist"}} = interaction) do
    GlobalWhitelist.handle(interaction)
  end

  def handle(interaction) do
    Logger.warn("Encountered unknown interaction '#{interaction.data.name}'")

    Reuniclus.InteractionHelper.respond_message(
      interaction,
      "Unknown command. How did I get here?"
    )
  end
end
