import Config

config :reuniclus, ecto_repos: [Reuniclus.Database.Repo]

config :reuniclus, Reuniclus.Database.Repo,
  database: "reuniclus",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :reuniclus,
  guild_id: 1092267676035993673,
  server_listing_channel_id: 1092268921664573440,
  unlock_interval_minutes: 1,
  unlocker_poll_rate_minutes: 1,
  bot_lock_cool_down_minutes: 1

config :nostrum,
  token: "ODY2NzI4NjI1MTEzNzkyNTMz.Gt5Jph.iJiInBG1lGPIkOVdwyT7okpI-nURw1rAxNTuks",
  gateway_intents: :all