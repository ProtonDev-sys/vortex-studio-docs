# Vector3

A three-component vector used for positions, sizes, directions, and transforms.

## Constructor and constants

| Member | Description |
| --- | --- |
| `Vector3.new(x?: number, y?: number, z?: number): Vector3` | Construct a vector. Missing components default to 0. |
| `Vector3.zero` | Vector3.new(0, 0, 0). |
| `Vector3.one` | Vector3.new(1, 1, 1). |
| `Vector3.xAxis / yAxis / zAxis` | Positive unit basis vectors. |

## Properties and methods

| Member | Description |
| --- | --- |
| `X / Y / Z: number` | Component properties. Lowercase x, y, and z are also stored on the value. |
| `Magnitude: number` | Euclidean vector length. |
| `Unit: Vector3` | Normalized vector. A zero vector returns Vector3.zero. |
| `vector:Dot(other: Vector3): number` | Dot product. |
| `vector:Cross(other: Vector3): Vector3` | Cross product. |
| `vector:Lerp(other: Vector3, alpha: number): Vector3` | Linear interpolation without clamping alpha. |

```luau
local Workspace = game:GetService("Workspace")
local mover = Workspace:WaitForChild("Mover")
local target = Workspace:WaitForChild("Target")
local offset = target.Position - mover.Position

if offset.Magnitude > 0 then
    mover.Position += offset.Unit * math.min(offset.Magnitude, 5)
end
```

## Operators

Vector3 supports +, -, unary -, and ==. Multiplication and division accept either a number or another Vector3 and apply component-wise when both operands are vectors.
