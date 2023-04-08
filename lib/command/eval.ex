defmodule Reuniclus.Command.Eval do
  @moduledoc "Handles the `/eval` command."

  import Reuniclus.InteractionHelper, only: [respond_message: 2, get_argument: 2]

  def command() do
    %{
      name: "eval",
      description: "Evaluates some input",
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

  def handle(interaction) do
    {result, _binding} =
      get_argument(interaction, "input")
      |> Code.eval_string([], __ENV__)

    respond_message(interaction, inspect(result))
  end
end
