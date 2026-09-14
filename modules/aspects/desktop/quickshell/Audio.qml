pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property int percentage: Math.round(Pipewire.defaultAudioSink.audio.volume * 100)
    readonly property bool muted: Pipewire.defaultAudioSink.audio.muted
}
