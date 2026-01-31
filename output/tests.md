Prompt (no docs):
"Build me a todo list app in Vapor (Zig WASM framework) with add, delete, and mark complete."

[Paste llms-minimal.md or llms-full.md]

Build a counter component with:

- A number display
- Increment button
- Decrement button

# What to check

State declared outside render
Correct imports
.children({}) syntax correct
.end() on Text
Button(handler) syntax correct

[Paste docs]

Build a todo list with:

- Text input for new todos
- Add button
- List of todos with delete button for each
- Mark complete toggle for each todo

# What to check

Vapor.arena(.persist).dupe() for string copying
Vapor.array(Item, .persist) for dynamic list
ButtonCtx for delete/toggle with index
Correct loop syntax for (items, 0..) |item, i|
TextField with .bind() and .end()

[Paste docs]

Build a login form with:

- Email input
- Password input
- Submit button
- Show error message if email is empty or missing @
- Submit on Enter key press

# What to check

onEvent(.keydown, handler) pattern
Event handler signature fn(evt: \*Vapor.Event) void
std.mem.eql(u8, evt.key(), "Enter")
evt.preventDefault()
Conditional error display

[Paste docs]

Build a card component with:

- White background
- Rounded corners (12px)
- Shadow
- Padding (24px)
- Centered content
- A title and description inside

Use a Style struct, not builder pattern.

# What to check

Correct Vapor.Style struct syntax
.style(&style_name)({}) syntax (not .children())
Visual properties in .visual = .{}

[Paste docs]

Build a modal that:

- Has a button to open it
- Shows a backdrop when open
- Has content and a close button
- Closes when clicking backdrop or close button

# What to check

Boolean state for show/hide
Conditional rendering with if (show_modal)
Proper z-index layering
Multiple buttons calling same close function
