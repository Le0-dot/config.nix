hl.bind("SUPER + CTRL + Q", hl.dsp.exit())
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + Tab", hl.dsp.window.fullscreen({ mode = 1 }))

hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))

hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1, silent = true }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2, silent = true }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3, silent = true }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4, silent = true }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5, silent = true }))

hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))

hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

hl.bind("SUPER + CTRL + H", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind("SUPER + CTRL + J", hl.dsp.workspace.move({ monitor = "d" }))
hl.bind("SUPER + CTRL + K", hl.dsp.workspace.move({ monitor = "u" }))
hl.bind("SUPER + CTRL + L", hl.dsp.workspace.move({ monitor = "r" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + F", hl.dsp.exec_cmd("google-chrome"))
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("ghostty +new-window"))
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("wlogout -b 2 -L 480 -R 480"))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("tofi-drun --drun-launch=true --padding-left=40%"))
hl.bind("SUPER + P",
    hl.dsp.exec_cmd(
        "choose-repo tofi ~/projects 3 | xargs -I{} ghostty -e direnv exec {} nvim -c 'WithSession {}/Session.vim' +new-window"))
hl.bind("SUPER + CTRL + V", hl.dsp.exec_cmd("clipselect tofi"))
hl.bind("SUPER + CTRL + SPACE", hl.dsp.exec_cmd("playerctl -a play-pause"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
