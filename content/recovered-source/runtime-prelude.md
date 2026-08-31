# Runtime prelude

The Luau layer behind scheduling, signals, tweening, and remote helpers.

## Contents

This prelude implements task scheduling, Debris, Signal and Connection, RunService.Heartbeat, TweenInfo, TweenService, and channel-based remote helpers. Native host callbacks handle timing, reporting, and transport.

| Member | Description |
| --- | --- |
| `task / Debris` | Coroutine scheduling and delayed cleanup. |
| `Signal / Connection` | Event connections, one-shot handlers, waiting, and dispatch. |
| `TweenInfo / TweenService` | Easing, playback state, repeats, reverses, delay, and completion. |
| `FireServer / OnRemoteEvent` | Low-level channel helpers backed by the native transport. |

## Source file

Read the complete runtime prelude below.

[VortexStudio_runtime_prelude.luau](/source/VortexStudio_runtime_prelude.luau)
