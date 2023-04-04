defmodule Reuniclus.EventConsumer.InteractionCreate do
  @moduledoc "Handles the `INTERACTION_CREATE` event."

  require Logger
  alias Nostrum.Struct.Interaction
  alias Reuniclus.Command.{
    Echo
  }

  def handle(%Interaction{data: %{name: "echo"}} = interaction) do
    Logger.info("Dispatching to echo command")
    Echo.handle(interaction)
  end

  @spec handle(Interaction.t()) :: :ok | nil
  def handle(interaction) do
    Logger.info("Encountered unknown interaction '#{interaction.data.name}'.")
    Reuniclus.InteractionHelper.respond_message(interaction, "Unknown command. How did I get here?")
  end

end
