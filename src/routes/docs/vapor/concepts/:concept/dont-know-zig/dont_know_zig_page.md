{#thats-ok}

# "I Don't Know Zig, That's OK"

**You don't need to know Zig to start building with Vapor.**

If you've written JavaScript, TypeScript, C, Java, or really any programming language, you already understand 90% of what you need. Zig just looks a little different.

This section will get you comfortable in about 10 minutes.

{#the-basics-variables}

### The Basics: Variables

```zig
// Mutable (can change)
var count = 0;
var name = "hello";

// Immutable (cannot change)
const max_size = 100;
const title = "My App";
```

`var` for things that change, `const` for things that don't.

**JavaScript equivalent:**

```js
let count = 0;
const maxSize = 100;
```

{#functions}

### Functions

```zig
fn sayHello() void {
    // do something
}

fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

- `void` means "returns nothing" (like `void` in TypeScript)
- `i32` means "32-bit integer" (just a number, that can be negative and positive)

**JavaScript equivalent:**

```js
function sayHello() {
  // do something
}

function add(a, b) {
  return a + b;
}
```

{#the-one-weird-type-strings}

### The One Weird Type: Strings

At first glance, this looks strange, in comparison to other languages, but it's actually incredibly handy.

```zig
var message: []const u8 = "Hello World";
```

What does `[]const u8` mean?

- `u8` = a byte (each character is a byte)
- `[]` = a bunch of them in a row (an array)
- `const` = the characters themselves can't be changed

**Translation:** "A string."

That's it. Whenever you see `[]const u8`, just think "string."

```zig
// These are all just strings
var greeting: []const u8 = "Hello";
var name: []const u8 = "Vapor";
const url: []const u8 = "/home";
```

⚠️ **Pro tip:** Zig often infers types, so you can frequently just write:

```zig
var greeting = "Hello";
```

#### Handiness

Since `[]const u8` is an array of bytes, you can index into it or pull out slices of it.

```zig
const hello_world: []const u8 = "Hello World";

// Index into the string
const first_letter = hello_world[0];

// Slice the string
const first_three_letters = hello_world[0..3];
```

This is a very handy feature, and is used throughout Vapor, for example with url paths.

{#if-statements}

### If Statements

```zig
if (count > 10) {
    // do something
} else {
    // do something else
}
```

Identical to JavaScript. No surprises here.

{#loops}

### Loops

```zig
// Loop through items
for (items) |item| {
    Text(item).end();
}

// With index
for (items, 0..) |item, index| {
    Text(item).end();
}

// While loop
while (count < 10) {
    count += 1;
}
```

**JavaScript equivalent:**

```js
for (const item of items) {
  // ...
}

items.forEach((item, index) => {
  // ...
});

while (count < 10) {
  count += 1;
}
```

The `|item|` syntax is called "capture" - it's just how Zig names the loop variable.

{#structs}

### Structs (Like Objects)

```zig
const User = struct {
    name: []const u8,
    age: u32,
};

var user = User{
    .name = "Alice",
    .age = 30,
};

// Access fields
const username = user.name;
```

**JavaScript equivalent:**

```js
const user = {
  name: "Alice",
  age: 30,
};

const username = user.name;
```

The only difference: Zig uses `.name = value` instead of `name: value`.

{#the-dot-brace-pattern}

### The Dot-Brace Pattern

You'll see this everywhere in Vapor:

```zig
Button(.{ .on_press = handleClick })
```

That `.{ }` is just an anonymous struct (like an inline object in JS):

```js
// JavaScript
Button({ onClick: handleClick })

// Zig
Button(.{ .on_press = handleClick })
```

Same concept, slightly different punctuation.

{#printing-debugging}

### Printing / Debugging

```zig
// Print to console
Vapor.print("Hello", .{});
Vapor.print("Count is: {d}", .{count});
Vapor.print("Name is: {s}", .{name});
```

The `{d}` means "digit" (number), `{s}` means "string". The `.{}` passes the values to insert.

**JavaScript equivalent:**

```js
console.log("Hello");
console.log(`Count is: ${count}`);
console.log(`Name is: ${name}`);
```

{#what-you-can-ignore}

### What You Can Ignore (For Now)

These Zig concepts exist but **you won't need them** to build UIs:

| Concept             | Why you can skip it                         |
| ------------------- | ------------------------------------------- |
| `comptime`          | Vapor uses it internally; you don't have to |
| Allocators / Arenas | Vapor manages memory for you                |
| Pointers (`*T`)     | Only needed for advanced patterns           |
| Error unions (`!T`) | Vapor handles errors internally             |
| Optionals (`?T`)    | You'll learn when you need it               |

{#a-complete-example}

### A Complete Example

Here's a real Vapor component. See if you can read it:

```zig
const Vapor = @import("vapor");
const Button = Vapor.Button;
const Text = Vapor.Text;
const Box = Vapor.Box;

var count: i32 = 0;
var message: []const u8 = "Click the button!";

fn handleClick() void {
    count += 1;
    if (count == 1) {
        message = "You clicked once!";
    } else {
        message = "Keep going!";
    }
}

pub fn render() void {
    Box().layout(.center).spacing(16).children({
        Text(message).font(18, 400, .black).end();

        Button(.{ .on_press = handleClick }).children({
            Text("Click me").font(16, 700, .white).end();
        });

        Text(count).font(24, 700, .blue).end();
    });
}
```

If you understood that, **you're ready to build with Vapor.**

{#quick-reference-card}

### Quick Reference Card

Keep this handy for your first few hours:

| JavaScript             | Zig                              |
| ---------------------- | -------------------------------- |
| `let x = 0`            | `var x: i32 = 0`                 |
| `const x = 0`          | `const x: i32 = 0`               |
| `"hello"`              | `"hello"` (type is `[]const u8`) |
| `function fn() {}`     | `fn name() void {}`              |
| `console.log(x)`       | `Vapor.print("{d}", .{x})`       |
| `for (const x of arr)` | `for (arr) \|x\|`                |
| `{ key: value }`       | `.{ .key = value }`              |
| `obj.method()`         | `obj.method()`                   |
| `// comment`           | `// comment`                     |

{#next-steps}

### Next Steps

Now that you're comfortable with the basics, you're ready to build something real.

Head over to [Making a Button](#making-a-button) to create your first interactive Vapor component.
