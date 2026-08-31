# Events and input

Signals emitted by Instances, gameplay state, and the client input service.

## Common events

| Member | Description |
| --- | --- |
| `Part.Touched: Signal` | A collision contact began. |
| `Part.TouchEnded: Signal` | A collision contact ended. |
| `Humanoid.HealthChanged: Signal` | Health changed. |
| `Humanoid.Died: Signal` | Health reached the death state. |

```luau
local pad = game:GetService("Workspace"):WaitForChild("DamagePad")
local idle = Color3.fromRGB(235, 80, 80)

pad.Touched:Connect(function()
    pad.Color = Color3.fromRGB(255, 210, 90)
end)

pad.TouchEnded:Connect(function()
    pad.Color = idle
end)
```

## UserInputService

UserInputService is client-only. Use the signals for edges and IsKeyDown when you need current state.

| Member | Description |
| --- | --- |
| `UserInputService.InputBegan: Signal` | Fires when a client input begins. |
| `UserInputService.InputEnded: Signal` | Fires when a client input ends. |
| `UserInputService:IsKeyDown(keyCode: Enum.KeyCode): boolean` | Return whether a keyboard key is currently held. |

```luau
local UserInputService = game:GetService("UserInputService")
local shiftHeld = false

local function updateShift()
    local isDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    if isDown == shiftHeld then
        return
    end

    shiftHeld = isDown
    print(isDown and "Shift pressed" or "Shift released")
end

UserInputService.InputBegan:Connect(updateShift)
UserInputService.InputEnded:Connect(updateShift)
```
