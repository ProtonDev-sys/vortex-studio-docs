# Language environment

Built-ins and standard libraries available to Vortex scripts.

## Built-ins

Use ordinary Luau primitives for guards, iteration, tables, and error handling.

| Member | Description |
| --- | --- |
| `type / typeof / tostring / tonumber / error` | Type inspection, conversion, and errors. |
| `print(...any)` | Write a line to the Studio Luau console. |
| `warn(...any)` | Write a warning line to the Studio Luau console. |
| `pairs / ipairs` | Table iteration. |
| `setmetatable` | Metatable assignment used by every Vortex datatype. |
| `pcall` | Protected calls used by tweens and server invokes. |

## Standard libraries

| Member | Description |
| --- | --- |
| `math` | Numeric functions used by Vector3, CFrame, and all easing implementations. |
| `string` | Formatting and pattern matching. |
| `table` | pack, unpack, insert, remove, and ordinary table operations. |
| `coroutine` | create, resume, yield, and status; integrated with the host scheduler. |
