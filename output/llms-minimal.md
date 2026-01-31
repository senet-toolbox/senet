# Vapor Minimal Reference

> Use builder pattern for styling. For Style structs, see llms-full.md

## ⚠️ CRITICAL RULES

### 1. State OUTSIDE render

```zig
var count: i32 = 0;           // ✅ Outside
fn render() void {
    var x: i32 = 0;           // ❌ Resets every frame!
}
```

### 2. Copy user input strings

```zig
fn save() void {
    // ❌ WRONG - points to reusable buffer
    saved = input;

    // ✅ CORRECT - copy to persistent memory
    const copy = Vapor.arena(.persist).dupe(u8, input) catch return;
    saved = copy;
}
```

### 3. Button vs ButtonCtx

```zig
// No parameters → Button
fn handleClick() void { }
Button(handleClick)

// With parameters → ButtonCtx
fn deleteItem(index: usize) void { }
ButtonCtx(deleteItem, .{index})

// ❌ WRONG - doesn't exist:
Button(deleteItem, .{index})
```

### 4. Element endings

```zig
// Containers → .children({})
Box().padding(.all(20)).children({
    Text("Hello").end();
});

// Leaf elements → .end()
Text("Hello").end();
TextField(.string).bind(&input).end();
```

---

## Imports

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Box = Vapor.Box;
const Text = Vapor.Text;
const Button = Vapor.Button;
const ButtonCtx = Vapor.ButtonCtx;
const TextField = Vapor.TextField;
const Stack = Vapor.Stack;
const Center = Vapor.Center;
const TextFmt = Vapor.TextFmt;
```

---

## Dynamic Arrays

```zig
const Item = struct {
    text: []const u8,
    done: bool = false,
};

var items: Vapor.Array(Item) = undefined;

pub fn init() void {
    items = Vapor.array(Item, .persist);
    Vapor.Page(.{ .src = @src() }, render, null);
}

fn addItem() void {
    const copy = Vapor.arena(.persist).dupe(u8, input) catch return;
    items.append(.{ .text = copy }) catch return;
}

fn deleteItem(index: usize) void {
    _ = items.orderedRemove(index);
}
```

---

## Styling (Builder Pattern Only)

### Layout & Spacing

```zig
Box()
    .layout(.center)              // center, left_center, top_left, x_between_center, etc.
    .direction(.column)           // .row or .column
    .spacing(16)                  // gap between children
    .padding(.all(20))            // .all(), .horizontal(), .vertical(), .tblr(t,b,l,r)
    .margin(.b(16))               // .t(), .b(), .l(), .r(), .all()
    .children({ });
```

### Sizing

```zig
Box()
    .width(.px(200))              // .px(), .percent(), .grow, .fit
    .height(.percent(100))
    .children({ });
```

### Colors & Background

```zig
Box()
    .background(.hex("#ffffff"))  // .hex(), .white, .transparent
    .children({ });

Text("Hello")
    .font(16, 400, .hex("#333333"))  // size, weight, color
    .end();
```

### Borders

```zig
Box()
    .border(.round(.hex("#e2e8f0"), .all(8)))  // color, radius
    .children({ });
```

### Interactivity

```zig
Button(handler)
    .hoverScale()                 // subtle scale on hover
    .cursor(.pointer)
    .children({ });
```

### Text Styling

```zig
Text("Hello")
    .font(16, 400, .hex("#333333"))     // size, weight, color
    .fontWeight(700)                     // override weight
    .textDecoration(.line_through)       // .none, .underline, .line_through
    .end();
```

---

## Events

### Keyboard (Enter to submit)

```zig
fn handleKeyDown(evt: *Vapor.Event) void {
    if (std.mem.eql(u8, evt.key(), "Enter")) {
        evt.preventDefault();
        submit();
    }
}

TextField(.string)
    .bind(&input)
    .onEvent(.keydown, handleKeyDown)
    .end();
```

---

## Loops

```zig
// With index (needed for delete/toggle)
for (items.items, 0..) |item, i| {
    Box().children({
        Text(item.text).end();
        ButtonCtx(deleteItem, .{i}).children({
            Text("X").end();
        });
    });
}
```
