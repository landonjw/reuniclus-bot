import Config

config :reuniclus, ecto_repos: [Reuniclus.Database.Repo]

config :reuniclus, Reuniclus.Database.Repo,
  database: "reuniclus",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :reuniclus,
  # List of forums to track and moderate. Servers are described as %{id: BigInt, bump_prevention: boolean}, with the id being the forum's channel id.
  forum_channels: [
    %{id: 1_092_268_921_664_573_440, bump_prevention: true},
    %{id: 1_092_943_521_826_226_176, bump_prevention: false}
  ]

config :reuniclus, BumpPrevention,
  # How long the thread is locked after a message has been sent.
  forum_lock_duration_minutes: 1,
  # How long a user has after creating a new thread before the bot will lock the channel for the first time.
  new_post_lock_timeout_minutes: 1

config :nostrum,
  token: "ODY2NzI4NjI1MTEzNzkyNTMz.Gl6b90.vuW45UgEEpAFUJnuHZRSnyrGjX_xS5sz4l2TsU",
  gateway_intents: :all
