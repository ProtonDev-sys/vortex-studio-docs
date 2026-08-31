# Execution model

Scripts run as cooperative Luau coroutines hosted by the Vortex engine.

## Scheduling

A script keeps control until it returns or yields. task.wait, Signal:Wait, and remote invokes resume after their timer, signal, or response is ready.

| Member | Description |
| --- | --- |
| `task.wait(seconds?: number): number?` | Yield for approximately the requested duration. The default is 0 seconds. |
| `Signal:Wait(): ...any` | Suspend until the next signal fire and return its arguments. |

```luau
local button = game:GetService("Workspace"):WaitForChild("Button")
local touchingPart = button.Touched:Wait()

button:SetAttribute("PressedBy", touchingPart.Name)
task.wait(0.25)
button:SetAttribute("PressedBy", nil)
```

## Script contexts

Script runs on the server, LocalScript runs on a client, and ModuleScript contains reusable Luau code. Remote direction and selected gameplay state are enforced by the native host.

## Heartbeat

RunService.Heartbeat fires once per engine update and passes the elapsed time in seconds. TweenService also advances its active tweens from this signal.

```luau
local RunService = game:GetService("RunService")
local platform = game:GetService("Workspace"):WaitForChild("Platform")

RunService.Heartbeat:Connect(function(deltaTime)
    platform.CFrame *= CFrame.Angles(0, deltaTime, 0)
end)
```
