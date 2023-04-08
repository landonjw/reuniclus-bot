defmodule Reuniclus.EventConsumer.GuildAvailable do
  @moduledoc "Handles the `GUILD_AVAILABLE` event."

  def handle(guild) do
    guild_id = guild.id
    Reuniclus.Commands.register_commands(guild_id)
  end
end
