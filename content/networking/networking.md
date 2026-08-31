# Remotes

RemoteEvent sends messages between client and server. RemoteFunction sends a request and waits for a response.

## RemoteEvent

| Member | Description |
| --- | --- |
| `remote:FireServer(...any)` | Client -> server. Calling from a server script raises an error. |
| `remote:FireClient(playerOrUserId, ...any)` | Server -> one client. Calling from a client script raises an error. |
| `remote:FireAllClients(...any)` | Server -> every client. Calling from a client script raises an error. |

### LocalScript

```luau
-- LocalScript
local remote = game:GetService("ReplicatedStorage"):FindFirstChild("GameEvent")

if remote then
    remote:FireServer("Ready")
end
```

### Script

```luau
-- Script
local remote = game:GetService("ReplicatedStorage"):FindFirstChild("GameEvent")

if remote then
    remote:FireAllClients("RoundStarted", 90)
end
```

## RemoteFunction

| Member | Description |
| --- | --- |
| `remote:InvokeServer(...any): ...any` | Client -> server request that yields for a response. |
| `remote.OnServerInvoke: function?` | Server callback used to produce the response. |

### Script

```luau
-- Script
local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ItemPrice")
local prices = { sword = 250, shield = 175 }

if remote then
    remote.OnServerInvoke = function(itemId)
        return prices[itemId]
    end
end
```

### LocalScript

```luau
-- LocalScript
local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ItemPrice")

if remote then
    local price = remote:InvokeServer("sword")
    if price then
        script:SetAttribute("DisplayedPrice", price)
    end
end
```

> [!NOTE]
> InvokeServer is client-only and has a per-frame queue guard.

## Serializable values

Remote payloads support primitive values, Vector3, Color3, lists, and maps. Keys must use supported primitive key types, and nested containers have a depth limit. Instances and CFrame values are rejected by this build.

### LocalScript

```luau
-- LocalScript
local remote = game:GetService("ReplicatedStorage"):FindFirstChild("GameEvent")

if remote then
    remote:FireServer({
        action = "Move",
        position = Vector3.new(0, 3, 0),
        color = Color3.fromRGB(255, 200, 80),
    })
end
```

> [!NOTE]
> Do not send Instances or CFrames through remotes. Send identifiers and numeric/vector data instead.

## Channel helpers

| Member | Description |
| --- | --- |
| `FireServer(channel: string, ...any)` | Low-level client channel helper. |
| `OnRemoteEvent(channel: string, fn: function): Connection` | Connect to `RemoteEvent.<channel>`. |

### LocalScript

```luau
-- LocalScript
FireServer("Chat", "hello")
```

### Script

```luau
-- Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

OnRemoteEvent("Chat", function(message)
    if type(message) == "string" then
        ReplicatedStorage:SetAttribute("LastChatMessage", message)
    end
end)
```
