defmodule Reuniclus.Commands do
  @moduledoc "Responsible for registering any discord commands."

  require Logger
  alias Nostrum.Api

  alias Reuniclus.Command.{
    Eval,
    Whitelist,
    GlobalWhitelist
  }

  defp register_command(guild_id, command) do
    Api.create_guild_application_command(guild_id, command)
  end

  def register_commands(guild_id) do
    Logger.info("Registering commands...")
    register_command(guild_id, Eval.command())
    register_command(guild_id, Whitelist.command())
    register_command(guild_id, GlobalWhitelist.command())
    Logger.info("Commands registered for guild #{guild_id}")
  end
end
