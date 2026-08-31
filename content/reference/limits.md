# Runtime limits

Hard guards enforced by the embedded runtime and native host.

## Limits

| Member | Description |
| --- | --- |
| `128 KiB Studio source limit` | The Studio Luau editor rejects larger snippets before queueing them. |
| `32 MiB Studio executor memory limit` | The standalone Studio executor sets this limit when it creates its Luau state. |
| `2 second Studio executor deadline` | The standalone executor stops snippets that overrun its native bounded call deadline. |
| `256 Studio console entries` | The console keeps the newest output records. |
| `4096 bytes per Studio console line` | Long print, warn, and error lines are clipped for display. |
| `512 Signal handlers` | Maximum connected handlers on one Signal. |
| `256 active tweens` | Maximum concurrent tweens managed by TweenService. |
| `512 RemoteEvent fires per frame` | Per-script/frame remote fire guard. |
| `50,000 property changes per frame` | Per-script/frame property mutation guard. |
| `Bounded remote nesting` | Deeply nested list/map payloads are rejected. |
| `Bounded pending task threads` | The host rejects scripts that accumulate too many pending scheduled threads. |

## Practical guidance

Reuse connections, batch state changes, cancel unused tweens, and keep remote payloads shallow. Runtime limits are safety ceilings, not targets.

```luau
-- LocalScript
local RunService = game:GetService("RunService")
local sensor = game:GetService("Workspace"):WaitForChild("Sensor")
local pending = {}

sensor.Touched:Connect(function(part)
    table.insert(pending, part.Name)
end)

RunService.Heartbeat:Connect(function()
    if #pending > 0 then
        FireServer("SensorTouches", pending)
        pending = {}
    end
end)
```
