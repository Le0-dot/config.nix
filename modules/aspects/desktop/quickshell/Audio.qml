pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Services.Pipewire

Singleton {
    id: audio

    readonly property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [audio.sink]
    }

    readonly property int percentage: Math.round(sink.audio.volume * 100)
    readonly property bool muted: sink.audio.muted
}
