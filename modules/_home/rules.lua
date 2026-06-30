hl.window_rule({ match = { tag = "main" }, workspace = 1 })
hl.window_rule({ match = { tag = "browser" }, workspace = 2 })
hl.window_rule({ match = { tag = "social" }, workspace = 3 })
hl.window_rule({ match = { tag = "video" }, workspace = 4 })
hl.window_rule({ match = { tag = "media" }, workspace = 5 })

hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { workspace = "w[tv1]", float = false }, border_size = 0, rounding = 0 })

hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { workspace = "f[1]", float = false }, border_size = 0, rounding = 0 })

hl.window_rule({ match = { tag = "video" }, opaque = true, no_dim = true, fullscreen = true })

hl.window_rule({ match = { class = ".*ghostty.*" }, tag = "+main" })
hl.window_rule({ match = { title = ".*Monkeytype.*" }, tag = "+main" })
hl.window_rule({ match = { class = "google-chrome" }, tag = "+browser" })
hl.window_rule({ match = { class = ".*Slack.*" }, tag = "+social" })
hl.window_rule({ match = { title = ".*Meet.*" }, tag = "+video" })
hl.window_rule({ match = { class = "spotify" }, tag = "+media" })
hl.window_rule({ match = { title = ".*Audiobookshelf.*" }, tag = "+media" })

hl.window_rule({ match = { class = "nm.*" }, float = true })
