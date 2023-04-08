defmodule Reuniclus.InteractionHelper do
  @moduledoc false

  alias Nostrum.Api

  def get_argument(interaction, name) do
    option =
      interaction.data.options
      |> Enum.filter(fn opt -> opt.name == name end)

    cond do
      Enum.empty?(option) ->
        nil

      true ->
        option |> hd |> Map.get(:value)
    end
  end

  def has_argument(interaction, name) do
    interaction.data.options
    |> Enum.filter(fn opt -> opt.name == name end)
    |> Enum.empty?()
    |> Kernel.not()
  end

  def respond_message(interaction, message) do
    response = %{
      type: 4,
      data: %{
        # Ephemeral
        flags: 64,
        content: message
      }
    }

    Api.create_interaction_response(interaction, response)
  end

  def respond_embed(interaction, title, description) do
    response = %{
      type: 4,
      data: %{
        # Ephemeral
        flags: 64,
        embeds: [
          %{
            title: title,
            description: description,
            color: 9_215_480,
            footer: %{
              text: "Reuniclus",
              icon_url:
                "https://www.models-resource.com/resources/big_icons/51/50055.png?updated=1651182463"
            },
            timestamp: DateTime.to_iso8601(DateTime.utc_now())
          }
        ]
      }
    }

    Api.create_interaction_response(interaction, response)
  end
end
