# Studio executor

The Studio Luau panel runs snippets through the same Vortex native runtime, with console capture and editor limits around it.

## Running snippets

Studio queues one snippet at a time for the next Vortex main tick. If the runtime is not ready, the queued snippet waits for the bootstrap step first.

| Member | Description |
| --- | --- |
| `Run` | Queue the current editor tab for execution. |
| `Ctrl+Enter` | Run the active editor tab from the source editor. |
| `8 editor tabs` | Maximum number of open Luau documents in the Studio panel. |

## Console output

print and warn are captured by the Studio console. Runtime errors are captured as error entries.

| Member | Description |
| --- | --- |
| `print(...any)` | Joins values with tabs and stores a print entry. |
| `warn(...any)` | Joins values with tabs and stores a warning entry. |
| `error(message: any)` | Stops the snippet and records the error text. |

```luau
print("Loaded", 3, "modules")
warn("Using fallback configuration")
error("Startup check failed")
```

## Snippet limits

The Studio executor is meant for short inspection and tooling snippets. Larger gameplay code still belongs in Script, LocalScript, or ModuleScript instances.

| Member | Description |
| --- | --- |
| `Source: 128 KiB` | The editor trims input at the UTF-8 boundary when a tab grows past the source limit. |
| `Memory: 32 MiB` | The executor configures this memory limit on the Luau state it creates. |
| `Deadline: 2 seconds` | A bounded native call stops snippets that do not finish in time. |
