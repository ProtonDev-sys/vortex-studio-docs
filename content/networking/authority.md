# Authority rules

The server owns remote direction and multiplayer character state.

## Client and server checks

| Member | Description |
| --- | --- |
| `FireServer / InvokeServer` | Client scripts only. |
| `FireClient / FireAllClients` | Server scripts only. |
| `UserInputService` | Unavailable to server scripts. |
| `Humanoid.Health writes` | Read-only from LocalScript; health is server-authoritative. |
| `Character state writes` | Read-only from LocalScript where guarded; character state is server-authoritative. |

## Pattern

Have the client request an action, validate it on the server, then let the server change authoritative state and notify clients.

### LocalScript

```luau
-- LocalScript
local targetId = "training-dummy"
FireServer("Attack", targetId)
```

### Script

```luau
-- Script
local Workspace = game:GetService("Workspace")
local allowedTargets = {
    ["training-dummy"] = true,
}

OnRemoteEvent("Attack", function(targetId)
    if type(targetId) ~= "string" or not allowedTargets[targetId] then
        return
    end

    local target = Workspace:FindFirstChild(targetId)
    if not target or not target:IsA("Part") then
        return
    end

    target:SetAttribute("LastHit", true)
end)
```
