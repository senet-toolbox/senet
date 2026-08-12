{#events-and-handlers}

# Events and Handlers

Events and Handlers in Vapor use a very similar approach to fetching.
We pass a callback and arguments, which is called when an event is triggered.

There are element event listeners and global event lisenters.

{#basic-event-listener}

### Basic event listener

Here is a basic example of an global event listener. Which listens for the `keydown` event, and then checks if the key pressed is `k` and the meta key is pressed.

```zig
const Vapor = @import("vapor");

fn onKeyPress(evt: *Vapor.Event) void {
    const key = evt.key();
    if (std.mem.eql(u8, key, "k") and evt.metaKey()) {
        evt.preventDefault();
        std.log.debug("Open dialog\n", .{});
    } else if (std.mem.eql(u8, key, "Escape")) {
        evt.preventDefault();
        std.log.debug("Close dialog\n", .{});
    }
}

fn mount() void {
    // Here we set a globally event listener for onKeyPress
    _ = Vapor.addGlobalListener(.keydown, onKeyPress);
}
```

{#binded-event-listener}

### Binded event listener

Binded is a struct that contains functions and fields of a native element, we can attach event listeners and mutate the underlying element.
We first create a binded element width `Binded{}`, and then attach a listener to it. By default, Vapor will auto attach ids to the binded element,
and update the values. For example, there is no need to do the typical `getText` and `setText` implementation.

```zig
const std = @import("std");
const Vapor = @import("vapor");
const Binded = Vapor.Binded;
const TextField = Vapor.TextField;
const Text = Vapor.Text;

var binded_textfield: Vapor.Binded = .{};
var text: []const u8 = "";
fn onWrite(evt: *Vapor.Event) void {
    const input_text = evt.text(); // this is from the event itself, only exsist within this function scope.
    std.log.debug("{s}", .{input_text});
}

fn onKeyUp(evt: *Vapor.Event) void {
    const key = evt.key(); // this is from the event itself
    std.log.debug("Last Key pressed: {s}", .{key});
}

fn mount() void {
    std.log.info("Mounted", .{});
    if (binded_textfield.getBoundingClientRect()) |bounds| {
        std.log.info("Bounds: {any}", .{bounds});
    }
    if (binded_textfield.getOffsets()) |offsets| {
        std.log.info("Offsets: {any}", .{offsets});
    }

}

pub fn render() void {
    TextField(.string)
        .ref(&binded_textfield)
        .bind(&text)
        .onMount(mount, .{})
        .onChange(onWrite, .{})
        .onEvent(.keyup, onKeyUp, .{})
        .focus() // immediatley focuses the element
        .end();
    Text(text).plain(); // text is updated automatically
}
```

{#type-safety}

### Type safety

Since we are using Zig, Vapor is type safe, and will not allow for events to be called on the wrong element.
For example, a `click` event will not work on non-buttons, or non-links Components, similarly, an `onChange` event will not work on a non-textfield
component. Vapor will return an error if this occurs.

{#field-saftey}

### Field saftey

Similarly, Vapor will disallow specific fields from being set, or retrieved from the element. The `key` field is not allowed on a Box component,
or a Text component, ect.
