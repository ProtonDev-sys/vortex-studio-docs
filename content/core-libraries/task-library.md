# task library

Functions for starting, delaying, and yielding Luau coroutines.

## Functions

| Member | Description |
| --- | --- |
| `task.wait(seconds?: number): number?` | Yield the current coroutine. Defaults to 0. |
| `task.spawn(fn: function, ...any): thread` | Create or resume a coroutine immediately. |
| `task.delay(seconds: number, fn: function, ...any): thread` | Schedule a coroutine through the native host after a delay. |
| `task.defer(fn: function, ...any): thread` | Equivalent to task.delay(0, fn, ...). |

```luau
local status = game:GetService("ReplicatedStorage"):WaitForChild("RoundStatus")

task.delay(10, function()
    status.Value = "Round over"
end)
```

## Compatibility aliases

The global wait, spawn, and delay functions forward to their task equivalents.

| Member | Description |
| --- | --- |
| `wait(seconds?: number)` | Alias of task.wait. |
| `spawn(fn: function)` | Alias of task.spawn. |
| `delay(seconds: number, fn: function)` | Alias of task.delay. |
