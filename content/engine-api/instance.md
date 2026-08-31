# Instance

The base object model for services, scene objects, scripts, values, and network endpoints.

## Hierarchy

| Member | Description |
| --- | --- |
| `Name: string` | Instance name. |
| `ClassName: string` | Read-only class name. |
| `Parent: Instance?` | Parent in the Instance tree. Assign an Instance or nil. |
| `instance:GetChildren(): {Instance}` | Direct children. |
| `instance:GetDescendants(): {Instance}` | All descendants. |
| `instance:FindFirstChild(name: string): Instance?` | Find a direct child by name. |
| `instance:WaitForChild(name: string, timeout?: number): Instance?` | Poll every 0.05 seconds until found or timed out. |
| `instance:FindFirstChildOfClass(className: string): Instance?` | Find a direct child by class. |
| `instance:IsA(className: string): boolean` | Test class identity/ancestry. |

```luau
local effects = game:GetService("ReplicatedStorage"):WaitForChild("Effects")

for _, item in ipairs(effects:GetDescendants()) do
    if item:IsA("Part") then
        item.Transparency = 0.5
    end
end
```

## Lifecycle

| Member | Description |
| --- | --- |
| `Instance.new(className: string): Instance` | Construct a supported class. See Instance classes for the supported constructor targets. |
| `instance:Destroy()` | Destroy the Instance. |
| `instance:Clone(): Instance` | Clone supported Instances; unsupported roots raise an error. |

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local template = ReplicatedStorage:WaitForChild("Explosion")
local effect = template:Clone()

effect.Parent = Workspace
task.delay(2, function()
    effect:Destroy()
end)
```

## Properties and attributes

| Member | Description |
| --- | --- |
| `instance:GetPropertyChangedSignal(property: string): Signal` | Signal for a named property. |
| `instance:SetAttribute(name: string, value: boolean \| number \| string \| nil)` | Set or remove an attribute. |
| `instance:GetAttribute(name: string): boolean \| number \| string \| nil` | Read one attribute. |
| `instance:GetAttributes(): {[string]: boolean \| number \| string}` | Return current attributes. |
| `instance:GetAttributeChangedSignal(name: string): Signal` | Signal for one attribute. |

```luau
local objective = game:GetService("Workspace"):WaitForChild("Objective")

objective:GetAttributeChangedSignal("Captured"):Connect(function()
    objective.Color = objective:GetAttribute("Captured")
        and Color3.fromRGB(90, 190, 120)
        or Color3.fromRGB(235, 80, 80)
end)
```

> [!NOTE]
> Attribute values are limited to nil, boolean, number, or string.
