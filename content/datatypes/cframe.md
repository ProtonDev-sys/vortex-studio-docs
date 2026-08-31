# CFrame

A position and rotation in 3D space.

## Constructors

| Member | Description |
| --- | --- |
| `CFrame.identity: CFrame` | Identity transform constant. |
| `CFrame.new(): CFrame` | Identity transform. |
| `CFrame.new(x: number, y: number, z: number): CFrame` | Translation-only transform. |
| `CFrame.new(position: Vector3): CFrame` | Translation from a vector. |
| `CFrame.new(at: Vector3, lookAt: Vector3, up?: Vector3): CFrame` | Look-at transform. |
| `CFrame.new(x, y, z, qx, qy, qz, qw): CFrame` | Quaternion transform. |
| `CFrame.new(x, y, z, r00, ..., r22): CFrame` | Transform from a 3x3 rotation matrix. |
| `CFrame.fromMatrix(position, right, up, back?): CFrame` | Construct from basis vectors. The final axis is computed when omitted. |
| `CFrame.lookAt(at, target, up?): CFrame` | Orient the negative Z axis toward target. |
| `CFrame.fromEulerAnglesXYZ(rx, ry, rz): CFrame` | XYZ Euler rotation. CFrame.Angles is an alias. |
| `CFrame.fromEulerAnglesYXZ(rx, ry, rz): CFrame` | YXZ Euler rotation. fromOrientation is an alias. |
| `CFrame.fromAxisAngle(axis, angle): CFrame` | Axis-angle rotation. |

```luau
local Workspace = game:GetService("Workspace")
local turret = Workspace:WaitForChild("Turret")
local target = Workspace:WaitForChild("Target")

turret.CFrame = CFrame.lookAt(turret.Position, target.Position)
```

## Properties

| Member | Description |
| --- | --- |
| `Position / p: Vector3` | Translation component. |
| `X / Y / Z: number` | Translation components. |
| `LookVector / RightVector / UpVector: Vector3` | World-space facing basis vectors. |
| `XVector / YVector / ZVector: Vector3` | Rotation matrix basis vectors. |
| `Rotation: CFrame` | Rotation component with its translation reset to zero. |

## Methods

| Member | Description |
| --- | --- |
| `cf:Inverse(): CFrame` | Inverse transform. |
| `cf:ToWorldSpace(other: CFrame): CFrame` | Compose cf * other. |
| `cf:ToObjectSpace(other: CFrame): CFrame` | Compose cf:Inverse() * other. |
| `cf:PointToWorldSpace(point: Vector3): Vector3` | Transform a point with translation. |
| `cf:PointToObjectSpace(point: Vector3): Vector3` | Inverse-transform a point. |
| `cf:VectorToWorldSpace(vector: Vector3): Vector3` | Rotate a vector without translation. |
| `cf:VectorToObjectSpace(vector: Vector3): Vector3` | Inverse-rotate a vector without translation. |
| `cf:GetComponents(): 12 numbers` | Return position followed by the 3x3 rotation matrix. components is an alias. |
| `cf:ToEulerAnglesXYZ(): number, number, number` | Extract XYZ Euler angles. toEulerAnglesXYZ is an alias. |
| `cf:ToEulerAnglesYXZ(): number, number, number` | Extract YXZ Euler angles. ToOrientation and toEulerAnglesYXZ are aliases. |
| `cf:Lerp(goal: CFrame, alpha: number): CFrame` | Interpolate position and orientation using the shortest quaternion path. |

```luau
local Workspace = game:GetService("Workspace")
local platform = Workspace:WaitForChild("Platform")
local marker = Workspace:WaitForChild("Marker")

marker.CFrame = platform.CFrame:ToWorldSpace(CFrame.new(0, 2, 0))
```

## Operators

CFrame multiplication composes transforms or transforms a Vector3 point. Adding or subtracting a Vector3 offsets the translation. Equality compares all stored position and quaternion components.
