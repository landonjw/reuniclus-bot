defmodule Reuniclus.Commands do
  @moduledoc "Responsible for registering any discord commands."

  require Logger
  alias Nostrum.Api
  alias Reuniclus.Command.{
    Echo
  }

  defp get_guild_id() do
    Application.fetch_env!(:reuniclus, :guild_id)
  end

  defp register_command(command) do
    guild_id = get_guild_id()
    Api.create_guild_application_command(guild_id, command)
  end

  def register_commands() do
    Logger.info("Registering commands...")
    register_command(Echo.command())
    Logger.info("Commands registered.")
  end
end