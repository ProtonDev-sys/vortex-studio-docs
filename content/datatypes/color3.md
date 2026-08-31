# Color3

A three-channel RGB color value.

## Members

| Member | Description |
| --- | --- |
| `Color3.new(r?: number, g?: number, b?: number): Color3` | Construct from normalized channel values. Missing channels default to 0. |
| `Color3.fromRGB(r: number, g: number, b: number): Color3` | Construct from 0-255 style channel values by dividing each value by 255. |
| `R / G / B: number` | Stored red, green, and blue channels. |
| `color:Lerp(other: Color3, alpha: number): Color3` | Linear interpolation without clamping alpha. |

```luau
local platform = game:GetService("Workspace"):WaitForChild("Platform")
local safe = Color3.fromRGB(90, 190, 120)
local danger = Color3.fromRGB(235, 80, 80)

platform.Color = safe:Lerp(danger, 0.35)
```

## Operators

Color3 supports equality and string conversion.
