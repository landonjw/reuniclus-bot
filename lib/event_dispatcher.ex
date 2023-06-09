defmodule Reuniclus.EventDispatcher.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [Reuniclus.EventDispatcher]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Reuniclus.EventDispatcher do
  use Nostrum.Consumer

  alias Reuniclus.EventConsumer.{
    InteractionCreate,
    MessageCreate,
    ThreadCreate,
    GuildAvailable,
    GuildAuditLogEntryCreate,
    Ready
  }

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    MessageCreate.handle(msg)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    InteractionCreate.handle(interaction)
  end

  def handle_event({:THREAD_CREATE, channel, _ws_state}) do
    ThreadCreate.handle(channel)
  end

  def handle_event({:GUILD_AVAILABLE, guild, _ws_state}) do
    GuildAvailable.handle(guild)
  end

  def handle_event({:GUILD_AUDIT_LOG_ENTRY_CREATE, guild, _ws_state}) do
    GuildAuditLogEntryCreate.handle(guild)
  end

  def handle_event({:READY, _event, _ws_state}) do
    Ready.handle()
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
