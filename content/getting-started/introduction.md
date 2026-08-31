# Introduction

Vortex Studio runs Luau scripts against its scene and multiplayer runtime.

## Overview

The runtime exposes a small Roblox-style API: Instances, engine services, Vector3, Color3, CFrame, signals, tasks, tweens, and remotes. If an API is not listed here, assume this build does not expose it.

## A first script

Services are reached through game:GetService. Instances use the same method-call syntax as ordinary Luau userdata.

```luau
local Workspace = game:GetService("Workspace")
local platform = Workspace:WaitForChild("Platform")

platform.Anchored = true
platform.Position = Vector3.new(0, 4, 0)
platform.Color = Color3.fromRGB(92, 170, 255)
```

## Version scope

This reference covers Vortex Studio v0.3.4. Later builds may add or change members.
