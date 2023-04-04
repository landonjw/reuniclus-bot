defmodule Reuniclus.Command.Echo do
  @moduledoc "Handles the `/echo` command."

  import Reuniclus.InteractionHelper, only: [respond_message: 2, get_argument: 2]

  def command() do
    %{
      name: "echo",
      description: "Echoes back some input",
      options: [
        %{
          # ApplicationCommandType::STRING
          type: 3,
          name: "input",
          description: "Input to echo",
          required: true
        }
      ]
    }
  end

  @spec handle(Interaction.t()) :: :ok | nil
  def handle(interaction) do
    input = get_argument(interaction, "input")
    respond_message(interaction, input)
  end
end