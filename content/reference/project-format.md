# .vrtx project format

VortexTool.dll writes versioned Vortex project files containing map data and V2 scripts.

## Container

| Member | Description |
| --- | --- |
| `Magic: VRTX` | Four-byte file signature. |
| `Version: 1` | Current container version. |
| `Payload: Zstandard` | Compressed project payload begins with the Zstandard frame magic. |

> [!NOTE]
> Project serialization is separate from the runtime remote-value codec.
