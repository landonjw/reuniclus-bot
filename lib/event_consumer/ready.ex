defmodule Reuniclus.EventConsumer.Ready do
  @moduledoc "Handles the `READY` event."

  def handle() do
    Reuniclus.Commands.register_commands()
  end

end
