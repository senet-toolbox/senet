# Vapor Framework - LLM Documentation

> Vapor is a Zig-based WebAssembly UI framework. Build web apps with native performance, no JavaScript frameworks required.

## Quick Links

| Document | Tokens | Use Case |
|----------|--------|----------|
| [llms-full.md](/llms/full.md) | ~18K | Complete reference, best results |
| [llms-minimal.md](/llms/minimal.md) | ~3K | Quick questions, limited context |

## Model Recommendations

| Model Tier | Examples | Expected Quality |
|------------|----------|------------------|
| **Best** | Claude Sonnet 3.5+, GPT-4o, Claude Opus | Excellent - handles all patterns |
| **Good** | Claude Haiku 3.5, GPT-4o-mini | Good - occasional syntax errors |
| **Limited** | GPT-3.5, older models | May struggle with Zig syntax |

## Critical Rules (Copy This First)

Before asking any Vapor question, paste these rules:
```
VAPOR FRAMEWORK RULES:
1. State variables go OUTSIDE render functions (not inside like React)
2. Copy user input strings: Vapor.arena(.persist).dupe(u8, input_text)
3. Containers use .children({}) OR .style(&s)({}) - never both
4. Leaf elements (Text, Icon, TextField) always end with .end()
5. Button(handler) takes no args; ButtonCtx(handler, .{args}) passes args
6. Loop with index: for (items, 0..) |item, i| { }
```

## Starter Prompt

Copy this complete prompt to begin:
```
I'm building with Vapor, a Zig-based WebAssembly UI framework.

Key concepts:
- State lives OUTSIDE render functions (variables inside render reset every frame)
- Use Vapor.arena(.persist).dupe(u8, text) to copy user input strings before storing
- Syntax: .children({}) for containers, .end() for leaf elements
- Button(fn) for no-arg handlers, ButtonCtx(fn, .{args}) to pass data
- Dynamic arrays: var items = Vapor.array(Item, .persist);

Standard imports:
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.ButtonCtx;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;

[YOUR QUESTION HERE]
```

## Common Tasks

### "Build me a todo list"
→ Use `llms-full.md`, search for "Complete Example: Todo List"

### "How do I handle form input?"
→ Key pattern: copy strings with `Vapor.arena(.persist).dupe(u8, input)`

### "How do I style components?"
→ Two ways: builder chain `.padding(.all(20)).children({})` or style struct `.style(&my_style)({})`

### "How do I pass data to button handlers?"
→ Use `ButtonCtx(handler, .{data})` instead of `Button(handler)`

## File Structure
```
your-project/
├── src/
│   ├── main.zig           # Entry point, Vapor.init(), routes
│   ├── routes/
│   │   └── home/
│   │       └── Page.zig   # Page components
│   └── components/        # Reusable components
└── web/
    └── index.html
```

## Need More Help?

- Full documentation: https://vapor.dev/docs
- GitHub: https://github.com/user/vapor
- Discord: https://discord.gg/vapor
