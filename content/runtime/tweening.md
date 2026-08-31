# Tweening

TweenService interpolates numeric and Lerp-capable properties over Heartbeat updates.

## TweenInfo

| Member | Description |
| --- | --- |
| `TweenInfo.new(time?, style?, direction?, repeatCount?, reverses?, delayTime?): TweenInfo` | Defaults: 1 second, Quad, Out, 0 repeats, no reverse, 0 delay. |
| `Time / EasingStyle / EasingDirection` | Duration and easing fields. |
| `RepeatCount / Reverses / DelayTime` | Looping and delay fields. |

## Tween

| Member | Description |
| --- | --- |
| `TweenService:Create(instance, info, goals): Tween` | Capture the target and goal property map. |
| `tween:Play()` | Begin or resume playback. |
| `tween:Pause()` | Pause an active tween. |
| `tween:Cancel()` | Stop playback and fire Completed with Enum.PlaybackState.Cancelled. |
| `tween.Completed: Signal` | Fires with the final PlaybackState. |
| `tween.PlaybackState: EnumItem` | Current state. |

```luau
local TweenService = game:GetService("TweenService")
local door = game:GetService("Workspace"):WaitForChild("Door")
local openPosition = door.Position + Vector3.new(0, door.Size.Y, 0)
local tween = TweenService:Create(
    door,
    TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    { Position = openPosition }
)

tween:Play()
```

> [!NOTE]
> The runtime allows up to 256 active tweens. A target whose Parent becomes nil is removed.
