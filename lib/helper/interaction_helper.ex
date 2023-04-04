defmodule Reuniclus.InteractionHelper do
  @moduledoc false

  alias Nostrum.Api
  alias Nostrum.Struct.Interaction

  @spec get_argument(Interaction.t(), String.t()) :: String.t() | nil
  def try_get_argument(interaction, name) do
    valid_args = Enum.filter(interaction.data.options, fn opt -> opt.name == name end)
    case valid_args do
      [] -> nil
      _ -> hd(valid_args)
    end
  end

  @spec get_argument(Interaction.t(), String.t()) :: String.t()
  def get_argument(interaction, name) do
    interaction.data.options
      |> Enum.filter(fn opt -> opt.name == name end)
      |> hd
      |> Map.get(:value)
  end

  @spec respond_message(Interaction.t(), String.t()) :: :ok | nil
  def respond_message(interaction, message) do
    response = %{
      type: 4,
      data: %{
        flags: 64, # Ephemeral
        content: message
      }
    }
    Api.create_interaction_response(interaction, response)
  end

  def respond_embed(interaction, message) do
    response = %{
      type: 4,
      data: %{
        flags: 64, # Ephemeral
        embeds: [
          %{
            description: message,
            color: 9215480,
            footer: %{
              text: "Reuniclus",
              icon_url: "https://www.models-resource.com/resources/big_icons/51/50055.png?updated=1651182463"
            },
            timestamp: DateTime.to_iso8601(DateTime.utc_now())
          }
        ]
      }
    }
    Api.create_interaction_response(interaction, response)
  end

end
