defmodule Reuniclus.ThreadHelper do
  @moduledoc false
  alias Nostrum.Api
  alias Reuniclus.Bridge.ThreadBridge
  alias Reuniclus.Database.Repo

  def lock_thread(thread) do
    thread |> ThreadBridge.lock_thread() |> Repo.update()
    Api.modify_channel(thread.channel_id, %{locked: true})
  end

  def unlock_thread(thread) do
    thread |> ThreadBridge.unlock_thread() |> Repo.update()
    Api.modify_channel(thread.channel_id, %{locked: false})
  end
end
