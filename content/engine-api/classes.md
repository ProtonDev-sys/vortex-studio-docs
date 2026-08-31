# Instance classes

Classes recognized by the native Instance bridge.

## Scene and containers

| Member | Description |
| --- | --- |
| `Workspace` | Spatial scene root. |
| `ReplicatedStorage` | Replicated object container. |
| `StarterPlayerScripts` | Client script template container. |
| `ServerScriptService` | Server script container. |
| `Model` | Group of scene Instances. |
| `Folder` | Generic hierarchy container. |

## World objects

| Member | Description |
| --- | --- |
| `Part` | 3D part with Position, Rotation/Orientation, CFrame, Size, Color, Transparency, Anchored, CanCollide, CastShadow, Touched, and TouchEnded. |
| `PointLight` | Point light Instance. |
| `SpotLight` | Directional spot light Instance. |
| `Humanoid` | Character health object with Health, HealthChanged, and Died. Health writes are server-authoritative. |
| `HumanoidRootPart` | Character root part class. |

```luau
local lamp = Instance.new("Part")
lamp.Name = "Lamp"
lamp.Anchored = true
lamp.Position = Vector3.new(0, 8, 0)
lamp.Parent = game:GetService("Workspace")

local light = Instance.new("PointLight")
light.Parent = lamp
```

## Part members

| Member | Description |
| --- | --- |
| `Position: Vector3` | World position. |
| `Rotation / Orientation: Vector3` | Euler rotation. |
| `CFrame: CFrame` | Full world transform. |
| `Size: Vector3` | Part dimensions. |
| `Color: Color3` | Surface color. |
| `Transparency: number` | Transparency value; must be a finite number. |
| `Anchored / CanCollide / CastShadow: boolean` | Physics and rendering flags. |
| `Touched / TouchEnded: Signal` | Collision begin/end signals. |

## Scripts, networking, and values

| Member | Description |
| --- | --- |
| `Script / LocalScript / ModuleScript` | Server, client, and reusable Luau script containers. |
| `RemoteEvent / RemoteFunction` | Client/server messaging endpoints. |
| `BindableEvent` | Local event endpoint. |
| `IntValue.Value: number` | Stored numeric value. |
| `StringValue.Value: string` | Stored text value. |
| `Player.Character: Model?` | The player's current character. |
| `Humanoid.Health: number` | Character health. Writes are server-authoritative. |

```luau
local score = Instance.new("IntValue")
score.Name = "Score"
score.Parent = game:GetService("ReplicatedStorage")

score:GetPropertyChangedSignal("Value"):Connect(function()
    score:SetAttribute("MilestoneReached", score.Value >= 100)
end)
```

> [!NOTE]
> Instance.new supports Part, Model, Folder, PointLight, SpotLight, LocalScript, Script, ModuleScript, RemoteEvent, BindableEvent, RemoteFunction, IntValue, and StringValue. Engine-owned roots and character objects are not constructor targets.
