# Enum

Named integer values used by input, tweening, materials, and playback state.

## Enum types

| Member | Description |
| --- | --- |
| `Enum.Material` | Smooth=1, Plastic=2, Wood=3, Metal=4, Grass=5, Ice=6, Paint=7. |
| `Enum.NormalId` | Right=0, Top=1, Back=2, Left=3, Bottom=4, Front=5. |
| `Enum.UserInputType` | MouseButton1=0, MouseButton2=1, MouseButton3=2, MouseWheel=3, MouseMovement=4, Touch=7, Keyboard=8, Focus=9, Gamepad1=12, None=19. |
| `Enum.EasingStyle` | Linear=0, Sine=1, Back=2, Quad=3, Quart=4, Quint=5, Bounce=6, Elastic=7, Exponential=8, Circular=9, Cubic=10. |
| `Enum.EasingDirection` | In=0, Out=1, InOut=2. |
| `Enum.PlaybackState` | Begin=0, Delayed=1, Playing=2, Paused=3, Completed=4, Cancelled=5. |

## EnumType and EnumItem

| Member | Description |
| --- | --- |
| `EnumType:GetEnumItems(): {EnumItem}` | Return a new array containing the type's items. |
| `EnumType:FromName(name: string): EnumItem?` | Look up an item by name. |
| `EnumType:FromValue(value: number): EnumItem?` | Look up an item by numeric value. |
| `EnumItem.Name: string` | Item name. |
| `EnumItem.Value: number` | Numeric value. |
| `EnumItem.EnumType: EnumType` | Owning enum type. |

## KeyCode values

KeyCode includes Backspace, Tab, Return, Escape, Space, punctuation keys, Zero-Nine, A-Z, Delete, arrow keys, left/right Shift, Control, Alt and Super, plus F1-F12. Letter and digit values use their ASCII codes; arrows are 17-20; function keys are 265-276.
