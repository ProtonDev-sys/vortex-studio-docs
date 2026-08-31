# Services

Singleton engine objects returned by game:GetService(name).

## Lookup

| Member | Description |
| --- | --- |
| `game:GetService(name: string): Instance` | Return the named service or raise an error for an invalid service. |

## Available services

| Member | Description |
| --- | --- |
| `Workspace` | Scene root and spatial Instance hierarchy. |
| `Players` | Player collection and LocalPlayer. |
| `RunService` | Execution context and Heartbeat. |
| `ReplicatedStorage` | Shared Instance container. |
| `StarterPlayerScripts` | Client script template container. |
| `ServerScriptService` | Server-only script container. |
| `Debris` | Delayed destruction. |
| `TweenService` | Property tween creation. |
| `UserInputService` | Client input queries. Unavailable on the server. |

## Service-specific members

| Member | Description |
| --- | --- |
| `Players.LocalPlayer: Player?` | The local client's Player. |
| `Debris:AddItem(item: Instance, lifetime?: number)` | Call Destroy after lifetime seconds; defaults to 10. |
| `Debris:SetMaxItems()` | Compatibility no-op. |
| `RunService.Heartbeat: Signal` | Frame update signal. |
| `TweenService:Create(instance, info, goals): Tween` | Create a Tween. |

```luau
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local spark = Instance.new("PointLight")

spark.Parent = Workspace:WaitForChild("Impact")
Debris:AddItem(spark, 0.15)
```
