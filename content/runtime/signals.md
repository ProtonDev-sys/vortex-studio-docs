# Signal

A synchronous event primitive with connections, one-shot handlers, and coroutine waiting.

## Members

| Member | Description |
| --- | --- |
| `Signal.new(name?: string): Signal` | Create a signal. |
| `signal:Connect(fn: function): Connection` | Register a handler. connect is an alias. |
| `signal:Once(fn: function): Connection` | Register a handler that disconnects before its first call. |
| `signal:Wait(): ...any` | Yield until the next Fire and return its arguments. |
| `signal:Fire(...any)` | Call a snapshot of connected handlers and resume current waiters. fire is an alias. |
| `connection:Disconnect()` | Disable the connection. disconnect is an alias. |

```luau
local roundChanged = Signal.new("RoundChanged")

roundChanged:Connect(function(roundNumber)
    game:GetService("ReplicatedStorage"):SetAttribute("Round", roundNumber)
end)

roundChanged:Fire(2)
```

> [!NOTE]
> A Signal accepts at most 512 connected handlers.
